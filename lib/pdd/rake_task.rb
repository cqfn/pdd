require 'rake'
require 'rake/tasklib'

# PDD Rake task
module PDD
  # Rake task
  class RakeTask < Rake::TaskLib
    attr_accessor :name
    def initialize(*args, &task_block)
      # @todo #125:30m Needs to have more parameters to run this task.
      #  For now, we just have a single parameter - the name.
      #  Needs more parameters like the xcop rake task has.
      @name = args.shift || :pdd
      desc 'Run PDD' unless ::Rake.application.last_description
      task(name, *args) do |_, task_args|
        RakeFileUtils.send(:verbose, true) do
          yield(*[self, task_args].slice(0, task_block.arity)) if block_given?
          run
        end
      end
    end

    def run
      # @todo #125:30m need to implement this method.
      #  For now, it's just a task,
      #  that accepts one parameter and throws a system error.
      abort('NOT IMPLEMENTED')
    end
  end
end
