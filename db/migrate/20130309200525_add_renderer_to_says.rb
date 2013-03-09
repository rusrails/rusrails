class AddRendererToSays < ActiveRecord::Migration
  def change
    add_column :says, :renderer, :string, :default => 'textile', :null => false
  end
end
