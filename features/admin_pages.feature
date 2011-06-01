Feature: administrating pages
  As a admin
  I want to manage pages and categories
  So I can create new content and correct existing
  
  Background:
    Given a admin with email "admin@domain.com" and password "123456"
    And I sign in as "admin@domain.com/123456"
    And a category named "Category 1" with URL match "category-1"
    And "Category 1" have a page named "Page 11" with URL match "page-11"
    And "Category 1" have a page named "Page 12" with URL match "page-12"
    And a category named "Category 2" with URL match "category-2"
    And "Category 2" have a page named "Page 21" with URL match "page-21"

  Scenario: listing categories
    When I follow "category_manager"
    Then I should see "Category 1"
    And I should see "Category 2"
  
  Scenario: creating category
    Given I am on the admin categories page
    When I follow "new_category"
    Then I should be on the new admin category page
    
    When I fill in the following:
      | category_name       | Category 3      |
      | category_text       | category 3 text |
      | category_url_match  | category-3      |
    And I check "category_enabled"
    And I press "category_submit"
    Then I should be on the admin categories page
    And I should see element ".notice"
    And I should see "Category 3"
  
  Scenario: creating category - failed
    Given I am on the new admin category page
    When I press "category_submit"
    Then I should be on the new admin category page
    And I should see element ".alert"
  
  @wip
  Scenario: editing category
    Given I am on the admin categories page
    When I follow "Category 1"
    Then I should be on the edit admin category "Category 1" page
    And the "category_name" field should contain "Category 1"
    And the "category_url_match" field should contain "category-1"
    
    When I fill in the following:
      | category_name       | Category Super  |
      | category_text       | category super  |
      | category_url_match  | category-super  |
    And I check "category_enabled"
    And I press "category_submit"
    Then I should be on the admin categories page
    And I should see element ".notice"
    And I should see "Category Super"
    And I should see element "a[href='/category-super']
  
  @wip
  Scenario: editing category - failed
    Given I am on the edit admin category "Category 1" page
    When I fill in the following:
      | category_name       ||
      | category_url_match  ||
    And I press "category_submit"
    Then I should be on the edit admin category "Category 1" page
    And I should see element ".alert"
  
  @wip
  Scenario: deleting category
    Given I am on the admin categories page
    When I follow "Удалить"
    Then I should not see "Category 1"
  
  Scenario: toggling activity of category
  
  Scenario: listing pages
  
  Scenario: creating page
  
  Scenario: creating page - failed
  
  Scenario: editing page
  
  Scenario: editing page - failed
  
  Scenario: deleting page