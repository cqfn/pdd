Feature: Applies Post-Parsing Rules
  As a source code writer I want to be sure that
  certain post-parsing rules are applied

  Scenario: Throwing exception on big estimates
    Given I have a "Sample.java" file with content:
    """
    @todo #13:180m This puzzle has too big estimate
    """
    When I run bin/pdd with "--rule=max-estimate:90"
    Then Exit code is not zero
    Then Stdout contains "bigger than 90 minutes"

  Scenario: Throwing exception on small estimates
    Given I have a "Sample.java" file with content:
    """
    @todo #13:15min This puzzle has too small estimate
    """
    When I run bin/pdd with "--rule=min-estimate:30"
    Then Exit code is not zero
    Then Stdout contains "lower than 30 minutes"

  Scenario: Throwing exception on duplicates
    Given I have a "Sample.java" file with content:
    """
    @todo #13:15min The text
    @todo #13:15min The text
    """
    When I run bin/pdd with ""
    Then Exit code is not zero
    Then Stdout contains "there are 2 duplicate"

  Scenario: Throwing exception on duplicates
    Given I have a "Sample.java" file with content:
    """
    @todo #13/DEV:15min Some text first
    @todo #13/TEST:15min The text second
    """
    When I run bin/pdd with "--rule=available-roles:DEV,ARC"
    Then Exit code is not zero
    Then Stdout contains "defines role TEST"

  Scenario: Throwing exception on touching max-duplicates rule
    Given I have a "Sample.java" file with content:
    """
    @todo #334:15m This is the puzzle
    @todo #35:30m This is the puzzle
    """
    When I run bin/pdd with "--rule=max-duplicates:3"
    Then Exit code is not zero
