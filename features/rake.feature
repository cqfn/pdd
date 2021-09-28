Feature: Rake Task
  As a source code writer I want to be able to
  run PDD from Rakefile
  Scenario: PDD can be used in Rakefile
    Given It is Unix
    And I have a "Rakefile" file with content:
    """
    require 'pdd/rake_task'
    PDD::RakeTask.new(:pdd) do |task|
      task.includes = ['a.txt']
    end
    """
    And I have a "a.txt" file with content:
    """
    \x40todo #55 hello!
    """

    When I run bash with "rake pdd"
    Then Exit code is zero


