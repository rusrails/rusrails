class AddOauthIdAndOauthToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :oauth_id, :string
    add_column :users, :oauth, :string
  end

  def self.down
    remove_column :users, :oauth
    remove_column :users, :oauth_id
  end
end
