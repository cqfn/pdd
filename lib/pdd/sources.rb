# Copyright (c) 2014-2024 Yegor Bugayenko
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

require 'rainbow'
require 'English'
require 'filemagic'
require_relative 'source'
require_relative '../../utils/glob'

module PDD
  # Code base abstraction
  class Sources
    # Ctor.
    # +dir+:: Directory with source code files
    def initialize(dir)
      @dir = File.absolute_path(dir)
      @exclude = ['.git/**/*']
      @include = []
    end

    # Fetch all sources.
    def fetch
      exclude_paths = @exclude.map do |ptn|
        Glob.new(File.join(@dir, ptn)).to_regexp
      end
      files = Dir.glob(
        File.join(@dir, '**/*'), File::FNM_DOTMATCH
      ).reject do |f|
        File.directory?(f) || exclude_paths.any? { |ptn| f.match(ptn) }
      end
      files += Dir.glob(
        @include.map { |ptn| File.join(@dir, ptn) }
      ).reject { |f| File.directory?(f) }
      files = files.uniq # remove duplicates
      files.reject { |f| binary?(f) }.map do |file|
        path = file[@dir.length + 1, file.length]
        VerboseSource.new(path, Source.new(file, path))
      end
    end

    def exclude(paths)
      paths = [] if paths.nil?
      paths = [paths] unless paths.is_a?(Array)
      @exclude.push(*paths)
      paths&.each do |path|
        PDD.log.info "#{Rainbow('Excluding').orange} #{path}"
      end
      self
    end

    def include(paths)
      paths = [] if paths.nil?
      paths = [paths] unless paths.is_a?(Array)
      @include.push(*paths)
      paths&.each do |path|
        PDD.log.info "#{Rainbow('Including').blue} #{path}"
      end
      self
    end

    private

    def binary?(file)
      if text_file?(file)
        false
      else
        PDD.log.info "#{file} is a binary file (#{File.size(file)} bytes)"
        true
      end
    end

    def text_file?(file)
      fm = FileMagic.new(FileMagic::MAGIC_MIME)
      type = fm.file(file)
      type =~ %r{^(text/|application/javascript)}
    ensure
      fm.close
    end
  end
end
