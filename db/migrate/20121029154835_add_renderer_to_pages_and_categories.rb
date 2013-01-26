class AddRendererToPagesAndCategories < ActiveRecord::Migration
  def change
    add_column :categories, :renderer, :string, :default => 'textile', :null => false
    add_column :pages, :renderer, :string, :default => 'textile', :null => false
  end
end
