Feature: JSON output
  As a source code writer I want to be able to
  call PDD as a command line tool, and retrieve an
  JSON report

  Scenario: JSON report building
    Given I have a "Sample.java" file with content:
    """
    public class Main {
      /**
       * @todo #13 Let's do json
       *  or maybe not json ":)"
       */
      public void main(String[] args) {
        // later
      }
    }
    """
    When I run bin/pdd with "-v -s . -f out.json --format=json"
    Then Exit code is zero
    And Stdout contains "Reading from root dir ."
    And Text File "out.json" contains "Let's do json or maybe not json “:)“"
