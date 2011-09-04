Feature: Discussion interesting questions
  As a visitor
  I want to ask question
  So other visitors can answer me

  Background:
    Given a user with email "user@user.com" and password "123456"
    And a user with email "other@user.com" and password "123456"

  @wip
  Scenario: View discussions
    When I go to the home page
    Then I should see element "a[href='/discussions']"

    When I go to the discussions page
    Then I should see ""

  @wip
  Scenario: Start discussion

  @wip
  Scenario: Continue discussion
