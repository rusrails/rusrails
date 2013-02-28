class RemoveCategoryReferencesFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :category_id
  end

  def down
    add_column :pages, :category_id, :integer
  end
end
