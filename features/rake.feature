Feature: Rake Task
  Scenario: For now we failed if run rake task
    Given It is Unix
    And I have a "Rakefile" file with content:
    """
    require 'pdd/rake_task'
    PDD::RakeTask.new
    """
    When I run bash with "rake pdd"
    Then Exit code is not zero
    # @todo #114:30m For now, there haven't a proper method to check STDERR.
    #  In this test I've tried to check the output with Stdout contains but there is not working.
    #  Needs a proper alternative to check stderr.
