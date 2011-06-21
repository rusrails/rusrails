Feature: navigating pages
  As a guest visitor
  I want to navigate between site pages
  So that can satisfy my interest in some information of this site
  
  Background:
    Given a category named "Category 1" with URL match "category-1"
    And "Category 1" have a page named "Page 11" with URL match "page-11"
    And a category named "Category 2" with URL match "category-2"
    And "Category 2" have a page named "Page 21" with URL match "page-21"

  Scenario: enter home page
    Given a page named "Home page" with URL match "home"
    And page "Home page" has text "Home page text"
    When I go to the home page
    Then I should see "Home page text"
    And I should see "Category 1" within ".menu a[href='/category-1']"
    And I should see "Category 2" within ".menu a[href='/category-2']"
    But I should not see element ".menu a[href='/category-1/page-11']"
    But I should not see element ".menu a[href='/category-2/page-21']"

  Scenario: enter category
    Given category "Category 1" has text "Category 1 text"
    When I go to the category "Category 1"
    Then I should see "Category 1 text"
    And I should see "Page 11" within "#content"
    And I should see "Page 11" within ".category_pages a[href='/category-1/page-11']"
    And I should see "Category 1" within ".menu li.selected a[href='/category-1']"
    And I should see "Category 2" within ".menu a[href='/category-2']"
    And I should see "Page 11" within ".menu a[href='/category-1/page-11']"
    But I should not see element ".menu a[href='/category-2/page-21']"
  
  Scenario: enter page
    Given page "Page 11" has text "Page 11 text"
    When I go to the page "Page 11"
    Then I should see "Page 11 text"
    And I should see "Category 1" within ".menu li.selected a[href='/category-1']"
    And I should see "Category 2" within ".menu a[href='/category-2']"
    And I should see "Page 11" within ".category_pages li.selected a[href='/category-1/page-11']"
    But I should not see element ".menu a[href='/category-2/page-21']"
  
  Scenario Outline: navigating between pages
    Given "Category 1" additionally have <number> page(s)
    When I go to <n>-th page
    Then I should see <prev> previous link
    And I should see <next> next link
    
    Scenarios:
      | number  | n | prev  | next  |
      | 0       | 1 | 0     | 0     |
      | 1       | 1 | 0     | 1     |
      | 1       | 2 | 1     | 0     |
      | 2       | 2 | 1     | 1     |
