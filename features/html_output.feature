Feature: HTML output
  As a source code writer I want to be able to
  call PDD as a command line tool, and retrieve an
  HTML report

  Scenario: HTML report building
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
    When I run bin/pdd with "-v -s . -f out.html --format=html"
    Then Exit code is zero
    And Stdout contains "Reading ."
    And XML file "out.html" matches "/html/body"
