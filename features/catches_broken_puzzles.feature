Feature: Catches Broken Puzzles
  As a source code writer I want to be sure that
  broken puzzles won't be processed and will
  cause runtime errors

  Scenario: Throwing exception on broken puzzles
    Given I have a "Sample.java" file with content:
    """
    public class Main {
      /**
       * Some other documentation
       * text that is not relevant to
       * the puzzle below.
       * @todo #13 This puzzle has an incorrect format
       * because it doesn't start with a space on
       * the second and the third lines
       */
      public void main(String[] args) {
        // later
      }
    }
    """
    When I run pdd it fails with "Space expected"
    When I run pdd it fails with "Sample.java:6"

  Scenario: Throwing exception on yet another broken puzzle
    Given I have a "Sample.java" file with content:
    """
    public class Main {
      //
      // @todo #13 This puzzle has an incorrect format
      // because there is no space character in the
      // second and third lines
      //
      public void main(String[] args) {
        // later
      }
    }
    """
    When I run pdd it fails with "Space expected"
