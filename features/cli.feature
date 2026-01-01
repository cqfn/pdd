# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
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
       * @todo #13 Привет, Let's do it later, dude
       *  or maybe even never :)
       */
      public void main(String[] args) {
        // later
      }
    }
    """
    When I run bin/pdd with "-v -s . -f out.xml"
    Then Exit code is zero
    And Stdout contains "Reading from root dir ."
    And XML file "out.xml" matches "/puzzles[count(puzzle)=1]"
    And XML file "out.xml" matches "//puzzle[starts-with(body,'Привет, Let')]"

  Scenario: Using basic rules
    Given I have a "sample.java" file with content:
    """
    Nothing
    """
    When I run bin/pdd with "-v -s . -f out.xml --rule min-words:20 --rule=available-roles:DEV,ARC,PO"
    Then Exit code is zero

  Scenario: Simple puzzles collecting into stdout
    Given I have a "Sample.txt" file with content:
    """
    ~~
    ~~ @todo #44 First
    ~~  and
    ~~ second
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

  Scenario: Excluding unnecessary files from .gitignore
    Given I have a "a/b/c/test.txt" file with content:
    """
    ~~ @todo #44 some puzzle to be excluded
    """
    And I have a "f/g/h/hello.md" file with content:
    """
    ~~ @todo #45 some puzzle to be excluded as well
    """
    And I have a ".gitignore" file with content:
    """
    # This is the list of patterns
    a/**/*
    !/f
    """
    When I run bin/pdd with "--skip-gitignore > out.xml"
    Then Exit code is zero
    And XML file "out.xml" matches "/puzzles/puzzle[./ticket='45']"
    And XML file "out.xml" matches "/puzzles[count(puzzle)=1]"

  Scenario: Excluding unnecessary files from .gitignore and ignore comments
    Given I have a "a/b/c/test.txt" file with content:
    """
    ~~ @todo #44 some puzzle to be excluded
    """
    And I have a "f/g/h/hello.md" file with content:
    """
    ~~ @todo #45 some puzzle to be excluded as well
    """
    And I have a ".gitignore" file with content:
    """
    # This is the list of patterns
    # a/**/*
    f/**/*
    """
    When I run bin/pdd with "--skip-gitignore > out.xml"
    Then Exit code is zero
    And XML file "out.xml" matches "/puzzles/puzzle[./ticket='44']"
    And XML file "out.xml" matches "/puzzles[count(puzzle)=1]"

  Scenario: Files from .gitignore is not excluded by default
    Given I have a "a/b/c/test.txt" file with content:
    """
    ~~ @todo #44 some puzzle to be excluded
    """
    And I have a "f/g/h/hello.md" file with content:
    """
    ~~ @todo #45 some puzzle to be excluded as well
    """
    And I have a ".gitignore" file with content:
    """
    # This is the list of patterns
    a/**/*
    !/f
    """
    When I run bin/pdd with "> out.xml"
    Then Exit code is zero
    And XML file "out.xml" matches "/puzzles/puzzle[./ticket='44']"
    And XML file "out.xml" matches "/puzzles/puzzle[./ticket='45']"
    And XML file "out.xml" matches "/puzzles[count(puzzle)=2]"

  Scenario: Rejects unknown options
    Given I have a "test.txt" file with content:
    """
    """
    When I run bin/pdd with "--some-unknown-option"
    Then Exit code is not zero
