require 'rake'
require 'rake/tasklib'
require 'minitest/autorun'
require 'nokogiri'
require 'tmpdir'
require 'slop'
require 'pdd'

# PDD Rake task
module PDD
  # Rake task
  class RakeTask < Rake::TaskLib
    attr_accessor :name, :fail_on_error, :includes, :license, :quiet

    def initialize(*args, &task_block)
      @name = args.shift || :pdd
      @includes = []
      @excludes = []
      @license = nil
      @quiet = false
      desc 'Run PDD' unless ::Rake.application.last_description
      task(name, *args) do |_, task_args|
        RakeFileUtils.send(:verbose, true) do
          yield(*[self, task_args].slice(0, task_block.arity)) if block_given?
          run
        end
      end
    end

    private

    def run
      # @todo #125:30m need to implement this method.
      #  For now, it's just a task,
      #  that prints a simple Running pdd... message to user
      puts 'Running pdd...' unless @quiet
    end
  end
end
