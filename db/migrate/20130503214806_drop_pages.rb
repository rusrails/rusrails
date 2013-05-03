class DropPages < ActiveRecord::Migration
  def up
    drop_table :pages
  end

  def down
    create_table "pages" do |t|
      t.string   "name"
      t.string   "url_match"
      t.text     "text",       :limit => 16777215,                        :null => false
      t.boolean  "enabled",                        :default => true
      t.integer  "show_order",                     :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "renderer",                       :default => "textile", :null => false
    end

    add_index "pages", ["url_match"], :name => "index_pages_on_url_match", :unique => true
  end
end
