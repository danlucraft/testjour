Feature: Subtraction
  In order to avoid silly mistakes
  As a math idiot 
  I want to be told the difference of two numbers

  Scenario: Subtract two numbers
    Given I have entered 10 into the calculator
    And I have entered 1 into the calculator
    When I press subtract
    Then the result should be 9 on the screen

  Scenario: Subtract two numbers
    Given I have entered 100 into the calculator
    And I have entered 1 into the calculator
    When I press subtract
    Then the result should be 99 on the screen

  Scenario: Subtract two numbers
    Given I have entered 10 into the calculator
    And I have entered 10 into the calculator
    When I press subtract
    Then the result should be 0 on the screen

  Scenario: Subtract two numbers
    Given I have entered 10 into the calculator
    And I have entered 100 into the calculator
    When I press subtract
    Then the result should be -90 on the screen
