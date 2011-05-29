Feature: admin zone
  As a admin
  I want to have admin zone
  So I can manage all models and settings in this web-application
  
  Background:
    Given a admin with email "admin@domain.com" and password "123456"

  Scenario: Non-autentificated entry
    Given I am not logged in
    When I go to the admin root page
    Then I should be signed out
  
  @wip
  Scenario: Admin is not signed up
    Given I am not logged in
    When I go to the admin root page
    And I sign in as "noadmin@domain.com/please"
    Then I should see "Invalid email or password."
    And I go to the admin root page
    And I should be signed out

  Scenario: Admin enters wrong password
    Given I am not logged in
    When I go to the admin root page
    And I sign in as "admin@domain.com/wrongpassword"
    Then I should see "Invalid email or password."
    And I go to the admin root page
    And I should be signed out

  Scenario: Admin signs in successfully with email
    Given I am not logged in
    When I go to the admin root page
    And I sign in as "admin@domain.com/123456"
    Then I should see "Signed in successfully."
    And I should be signed in
    And should see element ".admin_menu"
    
    When I return next time
    Then I should be already signed in
    
  Scenario: Admin signs out
    When I sign in as "admin@domain.com/123456"
    Then I should be signed in
    And I sign out
    And I should see "Signed out"
    
    When I return next time
    Then I should be signed out
      
  Scenario: Admin signs up not allowed
    Given I am not logged in
    When I go to the sign up page
    Then I go to the admin root page
      
  Scenario: I sign in and edit my account
    When I sign in as "admin@domain.com/123456"
    Then I should be signed in
    
    When I follow "edit_account"
    And I fill in "admin_email" with "super@domain.com"
    And I fill in "admin_password" with "foobar"
    And I fill in "admin_password_confirmation" with "foobar"
    And I fill in "current_password" with "123456"
    And I press "admin_update"
    Then I go to the admin root page
    And admin should have email "super@domain.com" and password "foobar"