Given /^a category named "([^"]*)" with URL match "([^"]*)"$/ do |name, url_match|
  Factory :category, :name => name, :url_match => url_match
end