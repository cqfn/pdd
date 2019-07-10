Feature: Rake Task
  Scenario: For now we failed if run rake task
    Given It is Unix
    And a file named "Rakefile" with:
    """
    require 'pdd/rake_task'
    PDD::RakeTask.new
    """
    # @todo #126:30m For now, there is a warning when I run the test.
    #  Needs to replace the current call to not deprecated one.
    When I run "rake bin/pdd"
    Then the exit status should be 1
    And the stderr should contain:
    """
    NOT IMPLEMENTED
    """
    When I remove a file named "Rakefile" with full force
    Then a file named "Rakefile" does not exist
