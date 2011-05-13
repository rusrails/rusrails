class Category < ActiveRecord::Base
  validates :name, :presence => true
  validates :url_match, :presence => true
end
