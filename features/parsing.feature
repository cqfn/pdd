Feature: Parsing
  As a source code writer I want to be able to
  collect all puzzles from all my text files and
  present them in XML format

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
    When I run pdd
    Then XML matches "/puzzles[count(puzzle)=1]"
    And XML matches "/puzzles/puzzle[file='Sample.java']"
