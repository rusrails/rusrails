class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :name
      t.string :url_match
      t.text :text, :null => false
      t.references :category
      t.boolean :enabled, :default => true
      t.integer :show_order, :default => 0

      t.timestamps
    end
    
    add_index :pages, :url_match, :unique => true
  end

  def self.down
    drop_table :pages
  end
end
