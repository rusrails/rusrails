class DropCategories < ActiveRecord::Migration
  def up
    drop_table :categories
  end

  def down
    create_table "categories", :force => true do |t|
      t.string   "name"
      t.string   "url_match"
      t.text     "text"
      t.boolean  "enabled",    :default => true
      t.integer  "show_order", :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "renderer",   :default => "textile", :null => false
    end

    add_index "categories", ["url_match"], :name => "index_categories_on_url_match", :unique => true
  end
end
