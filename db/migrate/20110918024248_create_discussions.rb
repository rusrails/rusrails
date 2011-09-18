class CreateDiscussions < ActiveRecord::Migration
  def self.up
    create_table :discussions do |t|
      t.string :title, :null => false
      t.references :subject, :polymorphic => true
      t.references :author, :polymorphic => true
      t.boolean :enabled, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :discussions
  end
end
