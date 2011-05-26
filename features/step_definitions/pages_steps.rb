Given /^a category named "([^"]*)" with URL match "([^"]*)"$/ do |name, url_match|
  Factory :category, :name => name, :url_match => url_match, :enabled => true
end

Given /^a page named "([^"]*)" with URL match "([^"]*)"$/ do |name, url_match|
  Factory :page, :name => name, :url_match => url_match, :enabled => true
end

Given /^"([^"]*)" have a page named "([^"]*)" with URL match "([^"]*)"$/ do
    |category_name, name, url_match|
  category = Category.find_by_name category_name 
  Factory :page, :name => name, :url_match => url_match, :category => category
end

Given /^page "([^"]*)" has text "([^"]*)"$/ do |name, text|
  page = Page.find_by_name name
  page.update_attributes :text => text
end

Then /^I should not see element "([^"]*)"$/ do |element|
  page.should have_no_selector(element)
end