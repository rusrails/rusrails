Feature: Discussion interesting questions
  As a visitor
  I want to ask question
  So other visitors can answer me

  Background:
    Given a user with email "user@user.com" and password "123456"
    And a user with email "other@user.com" and password "123456"
    And a discussion titled "Answer me please" has says:
      | text        | author          |
      | My question | user@user.com   |
      | My answer   | other@user.com  |

  Scenario: View discussions
    When I go to the home page
    Then I should see element "a[href='/discussions']"

    When I go to the discussions page
    Then I should see "Answer me please"

    When I follow "Answer me please"
    Then I should be on the discussion "Answer me please" page
    And I should see "Answer me please"
    And I should see "My question"
    And I should see "My answer"

  @wip
  Scenario: Start discussion

  @wip
  Scenario: Continue discussion
