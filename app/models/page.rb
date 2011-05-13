class Page < ActiveRecord::Base
  validates :name, :presence => true
  validates :url_match, :presence => true
  
  belongs_to :category
end
