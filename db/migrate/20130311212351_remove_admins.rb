class RemoveAdmins < ActiveRecord::Migration
  class Admin < ActiveRecord::Base
    has_many :discussions, :foreign_key => :author_id, :conditions => {:author_type => 'User'}
    has_many :says, :foreign_key => :author_id, :conditions => {:author_type => 'User'}
  end

  def up

    drop_table :admins
  end

  def down
    create_table "admins", :force => true do |t|
      t.string   "email",                                 :default => "", :null => false
      t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",                         :default => 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
