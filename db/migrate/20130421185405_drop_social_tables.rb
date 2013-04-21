class DropSocialTables < ActiveRecord::Migration
  def up
    drop_table :says
    drop_table :discussions
    drop_table :users
  end

  def down

    create_table "discussions", :force => true do |t|
      t.string   "title",                          :null => false
      t.integer  "subject_id"
      t.string   "subject_type"
      t.integer  "author_id"
      t.string   "author_type"
      t.boolean  "enabled",      :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "says", :force => true do |t|
      t.text     "text",                                 :null => false
      t.integer  "discussion_id"
      t.integer  "author_id"
      t.string   "author_type"
      t.boolean  "enabled",       :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "renderer",      :default => "textile", :null => false
    end

    create_table "users", :force => true do |t|
      t.string   "email",                                 :default => "",    :null => false
      t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",                         :default => 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.string   "name"
      t.boolean  "banned",                                :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "oauth_id"
      t.string   "oauth"
      t.boolean  "admin",                                 :default => false
    end

    add_index "users", ["email"], :name => "index_users_on_email", :unique => true
    add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  end
end
