Given /^a category named "([^"]*)" with URL match "([^"]*)"$/ do |name, url_match|
  Factory :category, :name => name, :url_match => url_match
end

Given /^"([^"]*)" have a page named "([^"]*)" with URL match "([^"]*)"$/ do
  |category, name, url_match|
  pending
end