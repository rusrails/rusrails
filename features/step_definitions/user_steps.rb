Given /^a user with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  Factory :user, :email => email, :password => password
end

Given /^I am logout as user$/ do
  visit('/admins/sign_out')
end

Given /^I am not logged in as user$/ do
  visit('/users/sign_out') # ensure that at least
end

When /^I sign in as user "(.*)\/(.*)"$/ do |email, password|
  Given %{I am not logged in}
  When %{I go to the sign in as user page}
  And %{I fill in "user_email" with "#{email}"}
  And %{I fill in "user_password" with "#{password}"}
  And %{I press "user_submit"}
end

When /^I return next time as user$/ do
  And %{I go to the root page}
end

Then /^I should be already signed in as user$/ do
  And %{I should see element "#user_logout"}
end

Then /^I should be signed in as user$/ do
  Then %{I should see element ".notice"}
  Then %{I should see element ".user_menu"}
end

Then /^I sign out as user$/ do
  visit('/users/sign_out')
end

Then /^I should be signed out as user$/ do
  And %{I should see element "form.user_new"}
  And %{I should not see element ".user_menu"}
end