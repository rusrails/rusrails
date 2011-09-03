@wip
Feature: enter admin zone
  As a visitor
  I want to have user account
  So I can ask questions, leave comments, subscribe, etc
  
  Background:
    Given a user with email "user@user.com" and password "123456"

  Scenario: Non-autentificated entry
    Given I am not logged in as user
    When I go to the root page
    Then I should be signed out as user
  
  Scenario: User is not signed up
    Given I am not logged in as user
    When I go to the root page
    And I sign in as user "nouser@domain.com/please"
    Then I should see element ".alert"
    
    When I go to the root page
    Then I should be signed out as user

  Scenario: User enters wrong password
    Given I am not logged in as user
    When I go to the root page
    And I sign in as "user@user.com/wrongpassword"
    Then I should see element ".alert"
    
    When I go to the root page
    Then I should be signed out as user

  Scenario: User signs in successfully with email
    Given I am not logged in as user
    When I go to the root page
    And I sign in as "user@user.com/123456"
    Then I should be signed in as user
    
    When I go to the root page
    Then I should be already signed in as user

  Scenario: User signs out
    When I sign in as "user@user.com/123456"
    Then I should be signed in as user
    
    When I sign out as user
    And I go to the root page
    Then I should be signed out as user
    
  Scenario: User signs up

  Scenario: I sign in and edit my account
    When I sign in as "user@user.com/123456"
    Then I should be signed in as user
    
    When I follow "user_edit"
    And I fill in "user_email" with "super@domain.com"
    And I fill in "user_password" with "foobar"
    And I fill in "user_password_confirmation" with "foobar"
    And I fill in "user_current_password" with "123456"
    And I press "user_submit"
    
    When I sign out as user
    And I sign in as "super@domain.com/foobar"
    Then I should be signed in as user