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

require 'shellwords'
require 'English'
require_relative 'source'

module PDD
  # Code base abstraction
  class Sources
    # Ctor.
    # +dir+:: Directory with source code files
    def initialize(dir, ptns = [])
      @dir = File.absolute_path(dir)
      @exclude = ptns + ['.git/**/*']
      @include = ptns + ['.git/**/*']
    end

    # Fetch all sources.
    def fetch
      files = Dir.glob(
        File.join(@dir, '**/*'), File::FNM_DOTMATCH
      ).reject { |f| File.directory?(f) }
      included = 0
      @include.each do |ptn|
        Dir.glob(File.join(@dir, ptn), File::FNM_DOTMATCH) do |f|
          files.keep_if { |i| i != f }
          included += 1
        end
      end
      PDD.log.info "#{files.size} file(s) found, #{included} files included"
      excluded = 0
      @exclude.each do |ptn|
        Dir.glob(File.join(@dir, ptn), File::FNM_DOTMATCH) do |f|
          files.delete_if { |i| i == f }
          excluded += 1
        end
      end
      PDD.log.info "#{files.size} file(s) found, #{excluded} excluded"
      files.reject { |f| binary?(f) }.map do |file|
        path = file[@dir.length + 1, file.length]
        VerboseSource.new(path, Source.new(file, path))
      end
    end

    def exclude(ptn)
      Sources.new(@dir, @exclude.push(ptn))
    end

    def include(ptn)
      Sources.new(@dir, @include.push(ptn))
    end

    private

    # @todo #98:30min Change the implementation of this method
    #  to also work in Windows machines. Investigate the possibility
    #  of use a gem for this. After that, remove the skip of the test
    #  `test_ignores_binary_files` in `test_sources.rb`.
    def binary?(file)
      return false if Gem.win_platform?
      `grep -qI '.' #{Shellwords.escape(file)}`
      if $CHILD_STATUS.success?
        false
      else
        PDD.log.info "#{file} is a binary file (#{File.size(file)} bytes)"
        true
      end
    end
  end
end
