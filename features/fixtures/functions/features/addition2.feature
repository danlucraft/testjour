Feature: Addition
  In order to avoid silly mistakes
  As a math idiot 
  I want to be told the sum of two numbers

  Scenario: Add two numbers
    Given I have entered 10 into the calculator
    And I have entered 1 into the calculator
    When I press add
    Then the result should be 11 on the screen

  Scenario: Add two numbers
    Given I have entered 100 into the calculator
    And I have entered 10 into the calculator
    When I press add
    Then the result should be 110 on the screen

  Scenario: Add two numbers
    Given I have entered 130 into the calculator
    And I have entered 13 into the calculator
    When I press add
    Then the result should be 143 on the screen

  Scenario: Add two numbers
    Given I have entered 109 into the calculator
    And I have entered 1 into the calculator
    When I press add
    Then the result should be 110 on the screen
