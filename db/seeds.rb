Redirect.delete_all

current_redirects = {
  '/getting-started-with-rails' => '/getting-started',
  '/rails-database-migrations' => '/active-record-migrations',
  '/active-record-query-interface' => '/active-record-querying',
  '/layouts-and-rendering-in-rails' => '/layouts-and-rendering',
  '/rails-form-helpers' => '/form-helpers',
  '/rails-routing' => '/routing',
  '/rails-internationalization-i18n-api' => '/i18n',
  '/a-guide-to-testing-rails-applications' => '/testing',
  '/ruby-on-rails-security-guide' => '/security',
  '/configuring-rails-applications' => '/configuring',
  '/a-guide-to-the-rails-command-line' => '/command-line',
  '/caching-with-rails-an-overview' => '/caching-with-rails',
  '/constant_autoloading_and_reloading' => '/autoloading-and-reloading-constants',
  '/classic_to_zeitwerk_howto' => '/classic-to-zeitwerk-howto',
  '/a-guide-to-the-rails-command-line' => '/command-line',
}

current_redirects.each do |from, to|
  Redirect.create :from => from, :to => to
end
