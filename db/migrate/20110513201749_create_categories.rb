class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.string :url_match
      t.text :text

      t.timestamps
    end
    add_index :categories, :url_match, :unique => true
  end

  def self.down
    drop_table :categories
  end
end
