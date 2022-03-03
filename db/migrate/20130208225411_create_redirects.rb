class CreateRedirects < ActiveRecord::Migration
  def change
    create_table :redirects do |t|
      t.string :from
      t.string :to

      t.timestamps
    end
  end
end
