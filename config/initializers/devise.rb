
Devise.setup do |config|

  config.mailer_sender = "admin@rusrails.ru"

  require 'devise/orm/active_record'

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]

  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 10

  # ==> Configuration for :confirmable
  # The time you want to give your user to confirm his account. During this time
  # he will be able to access your application without confirming. Default is 0.days
  # When confirm_within is zero, the user won't be able to sign in without confirming.
  # You can use this to let your user access some features of your application
  # without confirming the account, but blocking it after a certain period
  # (ie 2 days).
  # config.confirm_within = 2.days

  # Defines which key will be used when confirming an account
  # config.confirmation_keys = [ :email ]

  config.use_salt_as_remember_token = true

  config.reset_password_within = 2.hours

  config.omniauth :github, Settings.oauth.github.key, Settings.oauth.github.secret
  config.omniauth :twitter, Settings.oauth.twitter.key, Settings.oauth.twitter.secret
  config.omniauth :google_oauth2, Settings.oauth.google.key, Settings.oauth.google.secret, :name => 'google'

  config.router_name = :main_app
end
