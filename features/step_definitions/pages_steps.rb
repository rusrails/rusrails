Given /^a category named "([^"]*)" with URL match "([^"]*)"$/ do |name, url_match|
  Factory :category, :name => name, :url_match => url_match
end

Given /^"([^"]*)" have a page named "([^"]*)" with URL match "([^"]*)"$/ do
    |category_name, name, url_match|
  category = Category.find_by_name(category_name)
  Factory :page, :name => name, :url_match => url_match, :category => category
end