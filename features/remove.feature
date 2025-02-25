# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
Feature: Removing Puzzles
  As a source code writer I want to be able to
  remove PDD puzzles from source code

  Scenario: Removing puzzles from code
    Given I have a "a/test.txt" file with content:
    """
    Hello,
    # @todo #42 Bye!
    #  Bye!
    The End.
    """
    When I run bin/pdd with "-v --remove -f /dev/null"
    Then Exit code is zero
    And Stdout contains "1 puzzles removed from a/test.txt"
