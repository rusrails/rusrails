class CreateSays < ActiveRecord::Migration
  def self.up
    create_table :says do |t|
      t.text :text, :null => false
      t.references :discussion
      t.references :author, :polymorphic => true
      t.boolean :enabled, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :says
  end
end
