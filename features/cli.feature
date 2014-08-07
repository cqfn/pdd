Feature: Command Line Processing
  As a source code writer I want to be able to
  call PDD as a command line tool

  Scenario: Help can be printed
    When I run bin/pdd with "-h"
    Then Exit code is zero
    And Stdout contains "Usage: pdd"

  Scenario: Simple puzzles collecting
    Given I have a "Sample.java" file with content:
    """
    public class Main {
      /**
       * @todo #13 Let's do it later, dude
       *  or maybe even never :)
       */
      public void main(String[] args) {
        // later
      }
    }
    """
    When I run bin/pdd with "-v -s . -f out.xml"
    Then XML file "out.xml" matches "/puzzles[count(puzzle)=1]"
