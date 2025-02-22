# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
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
       * @todo This puzzle has an incorrect format
       * because it doesn't have a ticket number
       */
      public void main(String[] args) {
        // later
      }
    }
    """
    When I run pdd it fails with "Sample.java:6"
