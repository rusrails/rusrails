class ChangeTextTypeInPages < ActiveRecord::Migration
  def up
    change_column :pages, :text, :mediumtext
  end

  def down
    change_column :pages, :text, :text
  end
end
