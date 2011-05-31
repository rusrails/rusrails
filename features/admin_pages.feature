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

  @wip    
  Scenario: listing categories
    When I follow "category_manager"
    Then I should see "Category 1"
    And I should see "Category 2"
  
  @wip
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
    And I should see "Category 3"
  
  @wip
  Scenario: creating category - failed
    Given I am on the new admin category page
    When I press "category_submit"
    Then I should be on the new admin category page
    And I should see element ".error"
  
  Scenario: editing category
  
  Scenario: editing category - failed
  
  Scenario: deleting category
  
  Scenario: listing pages
  
  Scenario: creating page
  
  Scenario: creating page - failed
  
  Scenario: editing page
  
  Scenario: editing page - failed
  
  Scenario: deleting page