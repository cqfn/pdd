# encoding: utf-8
#
# Copyright (c) 2014-2017 Yegor Bugayenko
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
require 'shellwords'
require_relative '../pdd/puzzle'

module PDD
  # Source.
  class Source
    # Ctor.
    # +file+:: Absolute file name with source code
    # +path+:: Path to show (without full file name)
    def initialize(file, path)
      @file = file
      @path = path
    end

    # Fetch all puzzles.
    def puzzles
      PDD.log.info "Reading #{@path}..."
      re = %r{(.*(?:^|\s))@todo\s+#([\w\-\.:/]+)\s+(.+)}
      puzzles = []
      lines = File.readlines(@file)
      lines.each_with_index do |line, idx|
        begin
          re.match(line) do |match|
            puzzles << puzzle(lines.drop(idx + 1), match, idx)
          end
        rescue Error => ex
          raise Error, ["in line ##{idx + 1}", ex]
        rescue ArgumentError => ex
          raise Error, ["in line ##{idx + 1}", ex]
        end
      end
      lines.each_with_index do |line, idx|
        next unless line =~ /.*(^|\s)@todo\s+[^#]/
        raise Error, "@todo found, but puzzle can't be parsed in line ##{idx}, \
most probably because TODO is not followed by a puzzle marker, as this page \
explains: https://github.com/yegor256/pdd#how-to-format"
      end
      puzzles
    end

    private

    # Fetch puzzle
    def puzzle(lines, match, idx)
      tail = tail(lines, match[1])
      body = (match[3] + ' ' + tail.join(' ')).gsub(/\s+/, ' ').strip
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
against the rules explained here: https://github.com/yegor256/pdd#how-to-format"
      end
      {
        ticket: match[1],
        estimate: minutes(match[2], match[3]),
        role: match[4].nil? ? 'IMP' : match[4]
      }
    end

    # Parse minutes.
    def minutes(num, units)
      min = num.nil? ? 0 : Integer(num)
      min *= 60 if !units.nil? && units.start_with?('h')
      min
    end

    # Fetch puzzle tail (all lines after the first one)
    def tail(lines, prefix)
      lines
        .take_while { |t| t.start_with?(prefix) }
        .map { |t| t[prefix.length, t.length] }
        .take_while { |t| t =~ /^[ a-zA-Z0-9]/ }
        .each { |t| raise Error, 'Space expected' unless t.start_with?(' ') }
        .each { |t| raise Error, 'Too many spaces' if t =~ /^\s{2,}/ }
        .map { |t| t[1, t.length] }
    end

    # Git information at the line
    def git(pos)
      cmd = "cd #{Shellwords.escape(File.dirname(@file))} && \
git blame -L #{pos},#{pos} --porcelain \
#{Shellwords.escape(File.basename(@file))}"
      Hash[
        `#{cmd}`.split("\n").map do |line|
          if line =~ /^author /
            [:author, line.sub(/^author /, '')]
          elsif line =~ /^author-mail /
            [:email, line.sub(/^author-mail <(.+)>$/, '\1')]
          elsif line =~ /^author-time /
            [
              :time,
              Time.at(line.sub(/^author-time ([0-9]+)$/, '\1').to_i).utc.iso8601
            ]
          end
        end.compact
      ]
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
      raise Error, ["in #{@file}", ex]
    end
  end
end
