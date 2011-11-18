# encoding: utf-8
Given /^a admin with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  Factory :admin, :email => email, :password => password
end

Given /^I am logout$/ do
  visit('/admins/sign_out')
end

Given /^I am not logged in$/ do
  visit('/admins/sign_out') # ensure that at least
end

When /^I sign in as "(.*)\/(.*)"$/ do |email, password|
  step %{I am not logged in}
  step %{I go to the sign in page}
  step %{I fill in "admin_email" with "#{email}"}
  step %{I fill in "admin_password" with "#{password}"}
  step %{I press "Войти"}
end

When /^I return next time$/ do
  step %{I go to the admin root page}
end

When /^I submit edit form for category "([^"]*)"$/ do |name|
  step %{I submit "edit_category_#{Category.find_by_name(name).id}"}
end

When /^I submit edit form for page "([^"]*)"$/ do |name|
  step %{I submit "edit_page_#{Page.find_by_name(name).id}"}
end

Then /^I should be already signed in$/ do
  step %{I should see element "#admin_logout"}
end

Then /^I should be signed in$/ do
  step %{I should see element ".notice"}
  step %{I should see element ".admin_menu"}
end

Then /^I sign out$/ do
  visit('/admins/sign_out')
end

Then /^I should be signed out$/ do
  step %{I should see element "form.admin_new"}
  step %{I should not see element ".admin_menu"}
end

Then /^admin should have email "([^"]*)" and password "([^"]*)"$/ do |email, password|

end
