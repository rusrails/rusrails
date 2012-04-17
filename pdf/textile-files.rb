# just 'files' array with textile files

@@files = ['home.textile']

in_folder = '0-getting-started-with-rails'
@@files += %w[
  --getting-started-with-rails.textile
  0-this-guide-assumes.textile
  1-what-is-rails.textile
  2-creating-a-new-rails-project.textile
  3-hello-rails.textile
  5-creating-a-resource.textile
  6-adding-a-second-model.textile
  7-refactoring.textile
  8-deleting-comments.textile
  9-security.textile
  10-building-a-multi-model-form.textile
  11-view-helpers.textile
  12-whats-next.textile
  13-configuration-gotchas.textile
].map{|file_name| in_folder + '/' + file_name }


in_folder = '1-rails-database-migrations'
@@files += %w[
  --rails-database-migrations.textile
  0-anatomy-of-a-migration.textile
  1-creating-a-migration.textile
  2-writing-a-migration.textile
  3-running-migrations.textile
  4-using-models-in-your-migrations.textile
  5-schema-dumping-and-you.textile
  6-active-record-and-referential-integrity.textile
].map{|file_name| in_folder + '/' + file_name }


in_folder = '2-active-record-validations-and-callbacks'
@@files += %w[
  --active-record-validations-and-callbacks.textile
  0-the-object-lifecycle.textile
  1-validations-overview.textile
  2-validation-helpers.textile
  3-common-validation-options.textile
  4-conditional-validation.textile
  5-creating-custom-validation-methods.textile
  6-working-with-validation-errors.textile
  7-displaying-validation-errors-in-the-view.textile
  8-callbacks.textile
  9-observers.textile
  10-transaction-callbacks.textile
].map{|file_name| in_folder + '/' + file_name }
