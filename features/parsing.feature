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
    And XML matches "//puzzle[file='Sample.java']"
    And XML matches "//puzzle[ticket='13']"
    And XML matches "//puzzle[lines='3-4']"
    And XML matches "//puzzle[starts-with(body,'Let')]"
    And XML matches "//puzzle[role='DEV']"
    And XML matches "//puzzle[estimate='0']"

  Scenario: Multiple puzzles in one file
    Given I have a "test/a/b/c/Sample.java" file with content:
    """
    public class Main {
      /**
       * @todo #13 This one later
       * @todo #ABC-67:15min And this one ever later
       * @todo #F-78-3:2h/DEV This is for a developer
       *  who will join us later
       */
      public void main(String[] args) {
        // later
      }
    }
    """
    When I run pdd
    Then XML matches "/puzzles[count(puzzle)=3]"
    And XML matches "//puzzle[ticket='13' and lines='3-3']"
    And XML matches "//puzzle[ticket='13' and body='This one later']"
    And XML matches "//puzzle[ticket='ABC-67' and lines='4-4']"
    And XML matches "//puzzle[ticket='F-78-3' and lines='5-6']"
    And XML matches "//puzzle[ticket='ABC-67' and estimate='15']"
    And XML matches "//puzzle[ticket='F-78-3' and estimate='120']"
