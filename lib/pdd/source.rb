# Copyright (c) 2014-2021 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'digest/md5'
require 'net/http'
require 'json'
require 'shellwords'
require_relative '../pdd'
require_relative '../pdd/puzzle'

module PDD
  MARKERS = ["\x40todo", 'TODO:?'].freeze
  # Source.
  class Source
    # Ctor.
    # +file+:: Absolute file name with source code
    # +path+:: Path to show (without full file name)
    def initialize(file, path)
      @file = file
      @path = path
    end

    def match_markers(line)
      MARKERS.map do |mkr|
        %r{(.*(?:^|\s))#{mkr}\s+#([\w\-\.:/]+)\s+(.+)}.match(line)
      end.compact
    end

    # Fetch all puzzles.
    def puzzles
      PDD.log.info "Reading #{@path} ..."
      puzzles = []
      lines = File.readlines(@file, encoding: 'UTF-8')
      lines.each_with_index do |line, idx|
        begin
          check_rules(line)
          match_markers(line).each do |m|
            puzzles << puzzle(lines.drop(idx + 1), m, idx)
          end
        rescue Error, ArgumentError => ex
          message = "#{@path}:#{idx + 1} #{ex.message}"
          raise Error, message unless PDD.opts && PDD.opts['skip-errors']
          PDD.log.warn message
        end
      end
      puzzles
    end

    private

    def get_no_leading_space_error(todo)
      "#{todo} must have a leading space to become \
a puzzle, as this page explains: https://github.com/cqfn/pdd#how-to-format"
    end

    def get_no_puzzle_marker_error(todo)
      "#{todo} found, but puzzle can't be parsed, \
most probably because #{todo} is not followed by a puzzle marker, \
as this page explains: https://github.com/cqfn/pdd#how-to-format"
    end

    def get_space_after_hash_error(todo)
      "#{todo} found, but there is an unexpected space \
after the hash sign, it should not be there, \
see https://github.com/cqfn/pdd#how-to-format"
    end

    def check_rules(line)
      /[^\s]\x40todo/.match(line) do |_|
        raise Error, get_no_leading_space_error("\x40todo")
      end
      /\x40todo(?!\s+#)/.match(line) do |_|
        raise Error, get_no_puzzle_marker_error("\x40todo")
      end
      /\x40todo\s+#\s/.match(line) do |_|
        raise Error, get_space_after_hash_error("\x40todo")
      end
      /[^\s]TODO:?/.match(line) do |_|
        raise Error, get_no_leading_space_error('TODO')
      end
      /TODO(?!:?\s+#)/.match(line) do |_|
        raise Error, get_no_puzzle_marker_error('TODO')
      end
      /TODO:?\s+#\s/.match(line) do |_|
        raise Error, get_space_after_hash_error('TODO')
      end
    end

    # Fetch puzzle
    def puzzle(lines, match, idx)
      tail = tail(lines, match[1], idx)
      body = (match[3] + ' ' + tail.join(' ')).gsub(/\s+/, ' ').strip
      body = body.chomp('*/-->').strip
      marker = marker(match[2])
      Puzzle.new(
        marker.merge(
          id: "#{marker[:ticket]}-#{Digest::MD5.hexdigest(body)[0..7]}",
          lines: "#{idx + 1}-#{idx + tail.size + 1}",
          body: body,
          file: @path
        ).merge(git(idx + 1))
      )
    end

    # Parse a marker.
    def marker(text)
      re = %r{([\w\-\.]+)(?::(\d+)(?:(m|h)[a-z]*)?)?(?:/([A-Z]+))?}
      match = re.match(text)
      if match.nil?
        raise "Invalid puzzle marker \"#{text}\", most probably formatted \
against the rules explained here: https://github.com/cqfn/pdd#how-to-format"
      end
      {
        ticket: match[1],
        estimate: minutes(match[2], match[3]),
        role: match[4].nil? ? 'DEV' : match[4]
      }
    end

    # Parse minutes.
    def minutes(num, units)
      min = num.nil? ? 0 : Integer(num)
      min *= 60 if !units.nil? && units.start_with?('h')
      min
    end

    # Fetch puzzle tail (all lines after the first one)
    def tail(lines, prefix, start)
      lines
        .take_while { |t| match_markers(t).none? && t.start_with?(prefix) }
        .map { |t| t[prefix.length, t.length] }
        .take_while { |t| t =~ /^[ a-zA-Z0-9]/ }
        .each_with_index do |t, i|
          next if t.start_with?(' ')
          raise Error, "Space expected at #{start + i + 2}:#{prefix.length}; \
make sure all lines in the puzzle body have a single leading space."
        end
        .map { |t| t[1, t.length] }
    end

    # @todo #75:30min Let's make it possible to fetch Subversion data
    #  in a similar way as we are doing with Git. We should also just
    #  skip it if it's not SVN.

    # Git information at the line
    def git(pos)
      dir = Shellwords.escape(File.dirname(@file))
      name = Shellwords.escape(File.basename(@file))
      git = "cd #{dir} && git"
      if `#{git} rev-parse --is-inside-work-tree 2>/dev/null`.strip == 'true'
        cmd = "#{git} blame -L #{pos},#{pos} --porcelain #{name}"
        add_github_login(Hash[
          `#{cmd}`.split("\n").map do |line|
            if line =~ /^author /
              [:author, line.sub(/^author /, '')]
            elsif line =~ /^author-mail [^@]+@[^\.]+\..+/
              [:email, line.sub(/^author-mail <(.+)>$/, '\1')]
            elsif line =~ /^author-time /
              [
                :time,
                Time.at(
                  line.sub(/^author-time ([0-9]+)$/, '\1').to_i
                ).utc.iso8601
              ]
            end
          end.compact
        ])
      else
        {}
      end
    end

    def add_github_login(info)
      login = find_github_login(info)
      info[:author] = "@#{login}" unless login.empty?
      info
    end

    def get_json(query)
      uri = URI.parse(query)
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = uri.scheme == 'https'
      req = Net::HTTP::Get.new(uri.request_uri)
      req.set_content_type('application/json')
      res = http.request(req)
      JSON.parse res.body
    end

    def find_github_user(info)
      email, author = info.values_at(:email, :author)
      # if email is not defined, changes have not been committed
      return if email.nil?
      base_uri = 'https://api.github.com/search/users?per_page=1'
      query = base_uri + "&q=#{email}+in:email"
      json = get_json query
      # find user by name instead since users can make github email private
      unless json['total_count'].positive?
        return if author.nil?
        query = base_uri + "&q=#{author}+in:fullname"
        json = get_json query
      end
      json['items'].first
    end

    def find_github_login(info)
      user = find_github_user info
      user['login']
    rescue StandardError
      ''
    end
  end

  # Verbose Source.
  class VerboseSource
    # Ctor.
    # +file+:: Absolute file name with source code
    # +source+:: Instance of source
    def initialize(file, source)
      @file = file
      @source = source
    end

    # Fetch all puzzles.
    def puzzles
      @source.puzzles
    rescue Error => ex
      raise Error, "#{@file}; #{ex.message}"
    end
  end
end
