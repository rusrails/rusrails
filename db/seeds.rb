Redirect.delete_all

current_redirects = {
  '/rails-routing/breaking-up-a-large-route-file' => '/rails-routing',
  '/active-record-validations-and-callbacks/the-object-lifecycle' => '/different-guides/active-record-callbacks',
  '/active-record-validations-and-callbacks/callbacks' => '/different-guides/active-record-callbacks',
  '/active-record-validations-and-callbacks/observers' => '/different-guides/active-record-callbacks',
  '/action-mailer-basics/asynchronous' => '/action-mailer-basics',
  '/ruby-on-rails-security-guide/mass-assignment' => '/ruby-on-rails-security-guide',

  '/getting-started-with-rails/this-guide-assumes' => '/getting-started-with-rails',
  '/getting-started-with-rails/what-is-rails' => '/getting-started-with-rails',
  '/getting-started-with-rails/creating-a-new-rails-project' => '/getting-started-with-rails',
  '/getting-started-with-rails/hello-rails' => '/getting-started-with-rails',
  '/getting-started-with-rails/getting-up-and-running' => '/getting-started-with-rails',
  '/getting-started-with-rails/adding-a-second-model' => '/getting-started-with-rails',
  '/getting-started-with-rails/refactoring' => '/getting-started-with-rails',
  '/getting-started-with-rails/deleting-comments' => '/getting-started-with-rails',
  '/getting-started-with-rails/security' => '/getting-started-with-rails',
  '/getting-started-with-rails/whats-next' => '/getting-started-with-rails',
  '/getting-started-with-rails/configuration-gotchas' => '/getting-started-with-rails',
}

current_redirects.each do |from, to|
  Redirect.create :from => from, :to => to
end
