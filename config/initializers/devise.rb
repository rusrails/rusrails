
Devise.setup do |config|

  config.mailer_sender = "admin@rusrails.ru"

  require 'devise/orm/active_record'

  config.case_insensitive_keys = [ :email ]

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 10. If
  # using other encryptors, it sets how many times you want the password re-encrypted.
  config.stretches = 10

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

end
