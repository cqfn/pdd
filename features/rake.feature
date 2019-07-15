Feature: Rake Task
  Scenario: For now we failed if run rake task
    Given It is Unix
    And a file named "Rakefile" with:
    """
    require 'pdd/rake_task'
    PDD::RakeTask.new
    """
    When I run the following commands with `bash`:
    """bash
    rake pdd
    """
    Then the exit status should be 1
    And the stderr should contain:
    """
    NOT IMPLEMENTED
    """
    When I remove a file named "Rakefile" with full force
    Then a file named "Rakefile" does not exist
