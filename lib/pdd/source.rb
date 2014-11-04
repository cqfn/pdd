# encoding: utf-8
#
# Copyright (c) 2014 TechnoPark Corp.
# Copyright (c) 2014 Yegor Bugayenko
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

require 'pdd/puzzle'

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
      re = /(.*(?:^|\s))@todo\s+#([\w\-\.:\/]+)\s+(.+)/
      puzzles = []
      lines = File.readlines(@file)
      lines.each_with_index do |line, idx|
        re.match(line) do |match|
          puzzles << puzzle(lines.drop(idx + 1), match, idx)
        end
      end
      puzzles
    end

    private

    # Parse a marker.
    def marker(text)
      re = /([\w\d\-\.]+)(?::(\d+)(?:(m|h)[a-z]*)?)?(?:\/([A-Z]+))?/
      match = re.match(text)
      fail "invalid puzzle marker: #{text}" if match.nil?
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

    # Fetch puzzle
    def puzzle(lines, match, idx)
      begin
        tail = tail(lines, match[1])
      rescue Error => ex
        raise Error, "#{ex.message} line ##{idx}"
      end
      body = (match[3] + ' ' + tail.join(' ')).gsub(/\s+/, ' ').strip
      Puzzle.new(
        marker(match[2]).merge(
          lines: "#{idx + 1}-#{idx + tail.size + 1}",
          body: body,
          file: @path
        )
      )
    end

    # Fetch puzzle tail (all lines after the first one)
    def tail(lines, prefix)
      lines
        .take_while { |txt| txt.start_with?(prefix) }
        .map { |txt| txt[prefix.length, txt.length] }
        .take_while { |txt| txt =~ /^[ a-zA-Z0-9\-_]/ }
        .each { |txt| fail Error, 'Space expected' unless txt.start_with?(' ') }
        .each { |txt| fail Error, 'Too many spaces' if txt =~ /^\s{2,}/ }
        .map { |txt| txt[1, txt.length] }
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
      raise Error, "#{ex.message} in #{@file}"
    end
  end
end
