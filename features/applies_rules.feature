Feature: Applies Post-Parsing Rules
  As a source code writer I want to be sure that
  certain post-parsing rules are applied

  Scenario: Throwing exception on invalid estimate
    Given I have a "Sample.java" file with content:
    """
    @todo #13:180m This puzzle has too big estimate
    """
    When I run bin/pdd with "--rule=max-estimate:90"
    Then Exit code is not zero
    Then Stdout contains "Estimate is too big"

  Scenario: Throwing exception on invalid estimate
    Given I have a "Sample.java" file with content:
    """
    @todo #13:15min This puzzle has too small estimate
    """
    When I run bin/pdd with "--rule=min-estimate:30"
    Then Exit code is not zero
    Then Stdout contains "Estimate is too small"

