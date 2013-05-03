# This migration comes from static_docs (originally 20130502102206)
class CreateStaticDocsPages < ActiveRecord::Migration
  def change
    create_table :static_docs_pages do |t|
      t.string :title
      t.string :path
      t.string :namespace
      t.text :body, :limit => 64.kilobytes + 1
      t.string :extension

      t.timestamps
    end

    add_index :static_docs_pages, :path
    add_index :static_docs_pages, :namespace
  end
end
