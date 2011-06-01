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
  Given %{I am not logged in}
  When %{I go to the sign in page}
  And %{I fill in "admin_email" with "#{email}"}
  And %{I fill in "admin_password" with "#{password}"}
  And %{I press "admin_submit"}
end

When /^I return next time$/ do
  And %{I go to the admin root page}
end

Then /^I should be already signed in$/ do
  And %{I should see element "#admin_logout"}
end

Then /^I should be signed in$/ do
  Then %{I should see element ".notice"}
  Then %{I should see element ".admin_menu"}
end

Then /^I sign out$/ do
  visit('/admins/sign_out')
end

Then /^I should be signed out$/ do
  And %{I should see element "form.admin_new"}
  And %{I should not see element ".admin_menu"}
end

Then /^admin should have email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  
end