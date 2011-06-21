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
    And I should see element "a[href='/category-super']"

  Scenario: editing category - failed
    Given I am on the edit admin category "Category 1" page
    When I fill in the following:
      | category_name       ||
      | category_url_match  ||
    And I press "category_submit"
    Then I should be on the edit admin category "Category 1" page
    And I should see element ".alert"

  Scenario: deleting category
    Given I am on the admin categories page
    When I follow "Удалить" within xpath //tr[.//text()="Category 1"]
    Then I should not see "Category 1"

  Scenario: toggling activity of category
    Given I am on the admin categories page
    When I follow "Вкл." within xpath //tr[.//text()="Category 1"]
    Then I should see "Выкл." within xpath //tr[.//text()="Category 1"]
    
    When I follow "Выкл." within xpath //tr[.//text()="Category 1"]
    Then I should see "Вкл." within xpath //tr[.//text()="Category 1"]

  Scenario: changing show order of category
    Given I am on the admin categories page
    When I fill in "category_show_order" with "1" within xpath //tr[.//text()="Category 1"]
    And I submit edit form for category "Category 1"
    Then the "category_show_order" field should contain "1" within xpath //tr[.//text()="Category 1"]

  Scenario: listing pages
    When I follow "page_manager"
    Then I should see "Page 11"
    And I should see "Page 12"
    And I should see "Page 21"

  Scenario: filtering pages by category
    Given I am on the admin pages page
    When I select "Category 1" from "category_id"
    And I submit "category_filter_form"
    Then I should see "Page 11"
    And I should see "Page 12"
    But I should not see "Page 21"

  Scenario: creating page - saving
    Given I am on the admin pages page
    When I follow "new_page"
    Then I should be on the new admin page page
    
    When I fill in the following:
      | page_name       | Tiptoeing           |
      | page_text       | Lee plays Tiptoeing |
      | page_url_match  | tiptoeing           |
    And I select "Category 1" from "page_category_id"
    And I check "page_enabled"
    And I press "page_submit"
    Then I should be on the admin pages page
    And I should see element ".notice"
    And I should see "Tiptoeing"
    And I should see element "a[href='/category-1/tiptoeing']"

@wip
  Scenario: creating page - applying
    Given I am on the new admin page page
    When I fill in the following:
      | page_name       | Tiptoeing           |
      | page_text       | Lee plays Tiptoeing |
      | page_url_match  | tiptoeing           |
    And I select "Category 1" from "page_category_id"
    And I check "page_enabled"
    And I press "page_apply"
    Then I should be on the edit admin page "Tiptoeing" page
    And I should see element ".notice"
    And the "page_name" field should contain "Tiptoeing"
    And the "page_url_match" field should contain "tiptoeing"

  Scenario: creating page - failed
    Given I am on the new admin page page
    When I press "page_submit"
    Then I should be on the new admin page page
    And I should see element ".alert"

@wip
  Scenario: editing page
    Given I am on the admin pages page
    When I follow "Page 11"
    Then I should be on the edit admin page "Page 11" page
    And the "page_name" field should contain "Page 11"
    And the "page_url_match" field should contain "page-11"
    
    When I fill in the following:
      | page_name       | Tiptoeing           |
      | page_text       | Lee plays Tiptoeing |
      | page_url_match  | tiptoeing           |
    And I select "Category 2" from "page_category_id"
    When I press "page_apply"
    Then I should be on the edit admin page "Tiptoeing" page
    And I should see element ".notice"
    And the "page_name" field should contain "Tiptoeing"
    And the "page_url_match" field should contain "tiptoeing"
    
    When I press "page_submit"
    Then I should be on the admin pages page
    And I should see element ".notice"
    And I should see "Tiptoeing"
    And I should see element "a[href='/category-2/tiptoeing']"

  Scenario: editing page - failed
    Given I am on the edit admin page "Page 11" page
    When I fill in "page_url_match" with ""
    And I press "page_submit"
    Then I should be on the edit admin page "Page 11" page
    And I should see element ".alert"

  Scenario: deleting page
    Given I am on the admin pages page
    When I follow "Удалить" within xpath //tr[.//text()="Page 11"]
    Then I should not see "Page 11"

  Scenario: toggling activity of page
    Given I am on the admin pages page
    When I follow "Вкл." within xpath //tr[.//text()="Page 11"]
    Then I should see "Выкл." within xpath //tr[.//text()="Page 11"]
    
    When I follow "Выкл." within xpath //tr[.//text()="Page 11"]
    Then I should see "Вкл." within xpath //tr[.//text()="Page 11"]

  Scenario: changing show order of page
    Given I am on the admin pages page
    When I fill in "page_show_order" with "1" within xpath //tr[.//text()="Page 11"]
    And I submit edit form for page "Page 11"
    Then the "page_show_order" field should contain "1" within xpath //tr[.//text()="Page 11"]
