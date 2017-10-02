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

require 'shellwords'
require 'English'
require_relative 'source'

module PDD
  # Code base abstraction
  class Sources
    # Ctor.
    # +dir+:: Directory with source code files
    def initialize(dir, ptns = [])
      @dir = dir
      @exclude = ptns + ['.git/**/*']
    end

    # Fetch all sources.
    def fetch
      files = Dir.glob(
        File.join(@dir, '**/*'), File::FNM_DOTMATCH
      ).reject { |f| File.directory?(f) }
      excluded = 0
      @exclude.each do |ptn|
        Dir.glob(File.join(@dir, ptn), File::FNM_DOTMATCH) do |f|
          files.delete_if { |i| i == f }
          excluded += 1
        end
      end
      PDD.log.info "#{files.size} file(s) found, #{excluded} excluded"
      files.reject { |f| binary?(f) }.map do |file|
        VerboseSource.new(
          file,
          Source.new(file, file[@dir.length + 1, file.length])
        )
      end
    end

    def exclude(ptn)
      Sources.new(@dir, @exclude.push(ptn))
    end

    private

    def binary?(f)
      return false if Gem.win_platform?
      `grep -qI '.' #{Shellwords.escape(f)}`
      if $CHILD_STATUS.success?
        false
      else
        PDD.log.info "#{f} is a binary file (#{File.size(f)} bytes)"
        true
      end
    end
  end
end
