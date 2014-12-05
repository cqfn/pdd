Feature: Command Line Processing
  As a source code writer I want to be able to
  call PDD as a command line tool

  Scenario: Help can be printed
    When I run bin/pdd with "-h"
    Then Exit code is zero
    And Stdout contains "-v, --verbose"

  Scenario: Version can be printed
    When I run bin/pdd with "--version"
    Then Exit code is zero

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
    Then Exit code is zero
    And Stdout contains "reading ."
    And XML file "out.xml" matches "/puzzles[count(puzzle)=1]"

  Scenario: Simple puzzles collecting into stdout
    Given I have a "Sample.txt" file with content:
    """
    ~~
    ~~ @todo #44 First
    ~~  and second
    ~~
    """
    When I run bin/pdd with "> out.xml"
    Then Exit code is zero
    And Stdout is empty
    And XML file "out.xml" matches "/puzzles[count(puzzle)=1]"

  Scenario: Excluding unnecessary files
    Given I have a "a/b/c/test.txt" file with content:
    """
    ~~ @todo #44 some puzzle to be excluded
    """
    And I have a "f/g/h/hello.md" file with content:
    """
    ~~ @todo #44 some puzzle to be excluded as well
    """
    When I run bin/pdd with "-e f/g/**/*.md --exclude a/**/*.txt > out.xml"
    Then Exit code is zero
    And XML file "out.xml" matches "/puzzles[count(puzzle)=0]"

  Scenario: Rejects unknown options
    Given I have a "test.txt" file with content:
    """
    """
    When I run bin/pdd with "--some-unknown-option"
    Then Exit code is not zero
