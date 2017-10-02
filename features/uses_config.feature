Feature: Using .pdd config file
  As a source code writer I want to be able to
  call PDD as a command line tool and configure
  it via .pdd configuration file

  Scenario: Simple puzzles collecting
    Given I have a "Sample.java" file with content:
    """
    @todo #13 Let's do it later, dude
    """
    And I have a ".pdd" file with content:
    """
    --verbose
    --source=.
    --file=out.xml
    """
    When I run bin/pdd with ""
    Then Exit code is zero
    And Stdout contains "Reading ."
    And XML file "out.xml" matches "/puzzles[count(puzzle)=1]"

