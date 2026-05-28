# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'nokogiri'
require 'pdd'
require 'rake'
require 'rake/tasklib'
require 'slop'
require 'tmpdir'

# PDD Rake task
module PDD
  # Rake task
  class RakeTask < Rake::TaskLib
    attr_accessor :name, :fail_on_error, :includes, :license, :quiet

    def initialize(*args, &task_block)
      super()
      @name = args.shift || :pdd
      @includes = []
      @excludes = []
      @license = nil
      @quiet = false
      desc('Run PDD') unless ::Rake.application.last_description
      task(name, *args) do |_, task_args|
        RakeFileUtils.__send__(:verbose, true) do
          yield(*[self, task_args].slice(0, task_block.arity)) if block_given?
        end
      end
    end
  end
end
