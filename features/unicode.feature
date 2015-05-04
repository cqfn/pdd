Feature: Unicode
  As a source code writer I want to be able to
  work with Unicode files

  Scenario: Unicode on ASCII locale
    Given I have a "test.txt" file with content:
    """
    # @todo #44 привет, друзья
    """
    When I run bash with
    """
    LANG=C ruby -Ipdd/lib pdd/bin/pdd test.txt -v -f=/dev/null -e=pdd/**/*
    """
    Then Exit code is zero

  Scenario: Skip file with broken Unicode
    Given I have a "test.txt" file with content:
    """
    \xFF test
    # @todo #44 \xFF hey
    \xFF test again
    """
    When I run bin/pdd with "--exclude=test.txt --v -f=/dev/null"
    Then Stdout contains "excluding test.txt"
    Then Exit code is zero
