# just 'files' array with textile files

@@parts = [] # {:name=> 'name', :files=>[] }
# 'name'.html + 'name2'.html + ...  => one.pdf


@@names2file_name = {}

@@parts << { 
  :name=> 'home', 
  :files=> ['home.textile']
}
@@names2file_name['home'] = '_home.html'

in_folder = '0-getting-started-with-rails'
files0 = %w[
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

@@parts << { 
  :name=> in_folder, 
  :files=> files0
}
@@names2file_name['getting-started-with-rails'] = '_0-getting-started-with-rails.html'



in_folder = '1-rails-database-migrations'
files1 = %w[
  --rails-database-migrations.textile
  0-anatomy-of-a-migration.textile
  1-creating-a-migration.textile
  2-writing-a-migration.textile
  3-running-migrations.textile
  4-using-models-in-your-migrations.textile
  5-schema-dumping-and-you.textile
  6-active-record-and-referential-integrity.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files1
}
@@names2file_name['rails-database-migrations'] = '_1-rails-database-migrations.html'


in_folder = '2-active-record-validations-and-callbacks'
files2 = %w[
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

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['active-record-validations-and-callbacks'] = '_2-active-record-validations-and-callbacks.html'


# по той причине что по какой-то причине большие html файлы при конвертации wkhtmltopdf - содержат пустые страницы в конце,
# разбиваем на несколько html ов
# при этом ссылки вероятно не будут работать

in_folder = '3-active-record-associations'
files2 = %w[
  --active-record-associations.textile
  0-why-associations.textile
  1-the-types-of-associations-1.textile
  2-the-types-of-associations-2.textile
  3-tips-tricks-and-warnings.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['active-record-associations'] = '_3-active-record-associations.html'

in_folder = '3-active-record-associations'
files2 = %w[
  4-belongsto-association-reference.textile
  5-hasone-association-reference.textile
  6-hasmany-association-reference.textile
  7-hasandbelongstomany-association-reference.textile
  8-association-callbacks-and-extensions.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder + '2', 
  :files=> files2,
  :title=> 'Связи ActiveRecord (подробнее)' # в отдельном html - своя структура вложенности - поэтому делаем "обёрточный" верхний заголовок
}
@@names2file_name['active-record-associations2'] = '_3-active-record-associations2.html'


#in_folder = '3-active-record-associations'
#files2 = %w[
#  --active-record-associations.textile
#  0-why-associations.textile
#  1-the-types-of-associations-1.textile
#  2-the-types-of-associations-2.textile
#  3-tips-tricks-and-warnings.textile
#  4-belongsto-association-reference.textile
#  5-hasone-association-reference.textile
#  6-hasmany-association-reference.textile
#  7-hasandbelongstomany-association-reference.textile
#  8-association-callbacks-and-extensions.textile
#].map{|file_name| in_folder + '/' + file_name }

#@@parts << { 
#  :name=> in_folder, 
#  :files=> files2
#}
#@@names2file_name['active-record-associations'] = '_3-active-record-associations.html'



in_folder = '4-active-record-query-interface'
files2 = %w[
  --active-record-query-interface.textile
  0-retrieving-objects-from-the-database.textile
  1-conditions.textile
  2-find-options.textile
  3-joining-tables.textile
  4-eager-loading-associations.textile
  5-scopes.textile
  6-dynamic-finders.textile
  7-find-or-build-a-new-object.textile
  8-finding-by-sql.textile
  9-selectall.textile
  10-pluck.textile
  11-existence-of-objects.textile
  12-calculations.textile
  13-running-explain.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['active-record-query-interface'] = '_4-active-record-query-interface.html'



in_folder = '5-layouts-and-rendering-in-rails'
files2 = %w[
  --layouts-and-rendering-in-rails.textile
  0-overview-how-the-pieces-fit-together.textile
  1-creating-responses-1.textile
  2-creating-responses-2.textile
  3-structuring-layouts.textile
  4-structuring-layouts-2.textile
  5-structuring-layouts-3.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['layouts-and-rendering-in-rails'] = '_5-layouts-and-rendering-in-rails.html'



in_folder = '6-rails-form-helpers'
files2 = %w[
  --rails-form-helpers.textile
  0-dealing-with-basic-forms.textile
  1-dealing-with-model-objects.textile
  2-making-select-boxes-with-ease.textile
  3-using-date-and-time-form-helpers.textile
  4-uploading-files.textile
  5-customising-form-builders.textile
  6-understanding-parameter-naming-conventions.textile
  7-forms-to-external-resources.textile
  8-building-complex-forms.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['rails-form-helpers'] = '_6-rails-form-helpers.html'



in_folder = '7-action-controller-overview'
files2 = %w[
  --action-controller-overview.textile
  0-what-does-a-controller-do.textile
  1-methods-and-actions.textile
  2-parameters.textile
  3-session.textile
  4-cookies.textile
  5-rendering-xml-and-json-data.textile
  6-filters.textile
  7-request-forgery-protection.textile
  8-the-request-and-response-objects.textile
  9-http-authentications.textile
  10-streaming-and-file-downloads.textile
  11-parameter-filtering.textile
  12-rescue.textile
  13-force-https-protocol.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['action-controller-overview'] = '_7-action-controller-overview.html'


in_folder = '8-rails-routing'
files2 = %w[
  --rails-routing.textile
  0-the-purpose-of-the-rails-router.textile
  1-resource-routing-the-rails-default-1.textile
  2-resource-routing-the-rails-default-2.textile
  3-non-resourceful-routes.textile
  4-customizing-resourceful-routes.textile
  5-inspecting-and-testing-routes.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['rails-routing'] = '_8-rails-routing.html'



# так же разбиваем на 2 части
#in_folder = '9-active-support-core-extensions'
#files2 = %w[
#  --active-support-core-extensions.textile
#  0-how-to-load-core-extensions.textile
#  1-extensions-to-all-objects.textile
#  2-extensions-to-module.textile
#  3-extensions-to-class.textile
#  4-extensions-to-string.textile
#  5-extensions-to-numeric-integer-float.textile
#  6-extensions-to-enumerable.textile
#  7-extensions-to-array.textile
#  8-extensions-to-hash.textile
#  9-extensions-to-regexp.textile
#  10-extensions-to-range.textile
#  11-extensions-to-proc.textile
#  12-extensions-to-date.textile
#  13-extensions-to-datetime.textile
#  14-extensions-to-time.textile
#  15-extensions-to-process-file-nameerror-loaderror.textile
#].map{|file_name| in_folder + '/' + file_name }
#
#@@parts << { 
#  :name=> in_folder, 
#  :files=> files2
#}
#@@names2file_name['active-support-core-extensions'] = '_9-active-support-core-extensions.html'


in_folder = '9-active-support-core-extensions'
files2 = %w[
  --active-support-core-extensions.textile
  0-how-to-load-core-extensions.textile
  1-extensions-to-all-objects.textile
  2-extensions-to-module.textile
  3-extensions-to-class.textile
  4-extensions-to-string.textile
  5-extensions-to-numeric-integer-float.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['active-support-core-extensions'] = '_9-active-support-core-extensions.html'

in_folder = '9-active-support-core-extensions'
files2 = %w[
  6-extensions-to-enumerable.textile
  7-extensions-to-array.textile
  8-extensions-to-hash.textile
  9-extensions-to-regexp.textile
  10-extensions-to-range.textile
  11-extensions-to-proc.textile
  12-extensions-to-date.textile
  13-extensions-to-datetime.textile
  14-extensions-to-time.textile
  15-extensions-to-process-file-nameerror-loaderror.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder + '2', 
  :files=> files2,
  :title=>'Расширения ядра Active Support (продолжение)'
}
@@names2file_name['active-support-core-extensions2'] = '_9-active-support-core-extensions2.html'


in_folder = '10-rails-internationalization-i18n-api'
files2 = %w[
  --rails-internationalization-i18n-api.textile
  0-how-i18n-in-ruby-on-rails-works.textile
  1-setup-the-rails-application-for-internationalization.textile
  2-internationalizing-your-application.textile
  3-overview-of-the-i18n-api-features.textile
  4-how-to-store-your-custom-translations.textile
  5-customize-your-i18n-setup.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['rails-internationalization-i18n-api'] = '_10-rails-internationalization-i18n-api.html'


in_folder = '11-action-mailer-basics'
files2 = %w[
  --action-mailer-basics.textile
  0-sending-emails.textile
  1-receiving-emails.textile
  2-using-action-mailer-helpers.textile
  3-action-mailer-configuration.textile
  4-mailer-testing.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['action-mailer-basics'] = '_11-action-mailer-basics.html'


in_folder = '12-a-guide-to-testing-rails-applications'
files2 = %w[
  --a-guide-to-testing-rails-applications.textile
  0-why-write-tests-for-your-rails-applications.textile
  1-introduction-to-testing.textile
  2-unit-testing-your-models.textile
  3-functional-tests-for-your-controllers.textile
  4-integration-testing.textile
  5-rake-tasks-for-running-your-tests.textile
  6-brief-note-about-test-unit.textile
  7-setup-and-teardown.textile
  8-testing-routes.textile
  9-testing-your-mailers.textile
  10-other-testing-approaches.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['a-guide-to-testing-rails-applications'] = '_12-a-guide-to-testing-rails-applications.html'



in_folder = '13-ruby-on-rails-security-guide'
files2 = %w[
  --ruby-on-rails-security-guide.textile
  0-introduction.textile
  1-sessions.textile
  2-cross-site-request-forgery-csrf.textile
  3-redirection-and-files.textile
  4-intranet-and-admin-security.textile
  5-mass-assignment.textile
  6-user-management.textile
  7-injection.textile
  8-additional-resources.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['ruby-on-rails-security-guide'] = '_13-ruby-on-rails-security-guide.html'


in_folder = '14-debugging-rails-applications'
files2 = %w[
  --debugging-rails-applications.textile
  0-view-helpers-for-debugging.textile
  1-the-logger.textile
  2-debugging-with-ruby-debug.textile
  3-debugging-memory-leaks.textile
  4-plugins-for-debugging-references.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['debugging-rails-applications'] = '_14-debugging-rails-applications.html'





in_folder = '15-performance-testing-rails-applications'
files2 = %w[
  --performance-testing-rails-applications.textile
  0-performance-test-cases.textile
  1-command-line-tools.textile
  2-helper-methods.textile
  3-request-logging.textile
  4-useful-links-commercial-products.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['performance-testing-rails-applications'] = '_15-performance-testing-rails-applications.html'


in_folder = '16-configuring-rails-applications'
files2 = %w[
  --configuring-rails-applications.textile
  0-locations-for-initialization-code.textile
  1-configuring-rails-components.textile
  2-rails-environment-settings.textile
  3-initialization.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['configuring-rails-applications'] = '_16-configuring-rails-applications.html'




in_folder = '17-a-guide-to-the-rails-command-line'
files2 = %w[
  --a-guide-to-the-rails-command-line.textile
  0-command-line-basics.textile
  1-rake.textile
  2-the-rails-advanced-command-line.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['a-guide-to-the-rails-command-line'] = '_17-a-guide-to-the-rails-command-line.html'




in_folder = '18-caching-with-rails-an-overview'
files2 = %w[
  --caching-with-rails-an-overview.textile
  0-basic-caching.textile
  1-cache-stores.textile
  2-conditional-get-support.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['caching-with-rails-an-overview'] = '_18-caching-with-rails-an-overview.html'




in_folder = '19-asset-pipeline'
files2 = %w[
  --asset-pipeline.textile
  0-what-is-the-asset-pipeline.textile
  1-how-to-use-the-asset-pipeline.textile
  2-in-development.textile
  3-in-production.textile
  4-customizing-the-pipeline.textile
  6-adding-assets-to-your-gems.textile
  8-upgrading-from-old-versions-of-rails.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['asset-pipeline'] = '_19-asset-pipeline.html'




in_folder = '20-different-guides'
files2 = %w[
  --different-guides.textile
  25-engines.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files2
}
@@names2file_name['different-guides'] = '_20-different-guides.html'
