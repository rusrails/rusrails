@wip
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
  
  Scenario: creating category
  
  Scenario: editing category
  
  Scenario: deleting category
  
  Scenario: listing pages
  
  Scenario: creating page
  
  Scenario: editing page
  
  Scenario: deleting page