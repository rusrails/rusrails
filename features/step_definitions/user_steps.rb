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
  step %{I am not logged in}
  step %{I go to the sign in as user page}
  step %{I fill in "user_email" with "#{email}"}
  step %{I fill in "user_password" with "#{password}"}
  step %{I press "user_submit"}
end

When /^I return next time as user$/ do
  And %{I go to the root page}
end

Then /^I should be already signed in as user$/ do
  step %{I should see element "a[href='/users/sign_out']"}
end

Then /^I should be signed in as user$/ do
  step %{I should see element ".notice"}
  step %{I should see element "a[href='/users/sign_out']"}
end

Then /^I sign out as user$/ do
  visit('/users/sign_out')
end

Then /^I should be signed out as user$/ do
  step %{I should see element "a[href='/users/sign_in']"}
  step %{I should not see element "a[href='/users/sign_out']"}
end
