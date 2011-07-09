@no-txn
Feature: searching pages
  As a guest visitor
  I want to search page by keywords
  So that can give me list of page that contains necessary information

@wip
Scenario: search
  Given a category named "Radio" with URL match "radio"
  And category "Radio" has text "Music speak"
  And "Radio" have a page named "The Music Stopped" with URL match "the-music-stopped"
  And page "The Music Stopped" has text "We were still dancing"
  And "Radio" have a page named "Far Away" with URL match "far-away"
  And page "Far Away" has text "Long ago and far away"
  And the Sphinx indexes are updated
  When I go to the home page
  And I fill in "search" with "music"
  And I press "search"
  Then I should be on the search page
  And I should see "Radio" within "#content a[href='/radio']"
  And I should see "The Music Stopped" within "#content a[href='/radio/the-music-stopped']"
  But I should not see "Far Away" within "#content"
