Feature: admin zone
  As a admin
  I want to have admin zone
  So I can manage all models and settings in this web-application
  
  Background:
    Given a admin with email "admin@domain.com" and password "123456"
  
  @wip
  Scenario: logging in
    When I go to the admin page
    Then I should see element "form.sign_in_form"
    And I should not see element ".admin_menu"
    
    When I fill in "admin_email" with "admin@domain.com"
    And I fill in "admin_password" with "123456"
    And I press "submit"
    Then I should see element ".admin_menu"
  
  Scenario: changing credentials
    When I signed in as admin
    
  
  Scenario: logging out