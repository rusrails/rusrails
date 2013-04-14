class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name

  has_many :discussions, as: :author
  has_many :says, as: :author

  def name
    read_attribute(:name) || email.split('@').first
  end

  def update_with_password(params={})
    if oauth
      params.except! :current_password, :email, :password, :password_confirmation
      update_without_password params
    else
      super
    end
  end

  def self.find_or_create_for_github(response)
    data = response.info
    if user = User.where(oauth_id: response.uid, oauth: 'github').first
      user
    else
      user = User.new email: "#{data.email}.github", password: Devise.friendly_token[0,20], name: data.name
      user.oauth_id = response.uid
      user.oauth = 'github'
      user.save
      user
    end
  end

  def self.find_or_create_for_twitter(response)
    data = response.info
    if user = User.where(oauth_id: response.uid, oauth: 'twitter').first
      user
    else
      user = User.new email: "#{response.uid}@#{data.nickname}.twitter", password: Devise.friendly_token[0,20], name: data.name
      user.oauth_id = response.uid
      user.oauth = 'twitter'
      user.save
      user
    end
  end

  def self.find_or_create_for_google(response)
    data = response.info
    if user = User.where(oauth_id: data.email, oauth: 'google').first
      user
    else
      user = User.new email: "#{data.email}.google", password: Devise.friendly_token[0,20]
      user.oauth_id = data.email
      user.oauth = 'google'
      user.save
      user
    end
  end
end
