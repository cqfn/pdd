Feature: Avoiding Duplicate Puzzles
  As a source code writer I want to be sure that
  XML output doesn't contain any duplicates

  Scenario: Throwing exception on duplicates
    Given I have a "Sample.java" file with content:
    """
    public class Main {
      /**
       * @todo #13 A simple puzzle
       * @todo #15 A simple puzzle
       */
      public void main(String[] args) {
        // later
      }
    }
    """
    When I run pdd it fails with "errors, see log above"
