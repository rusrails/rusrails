class Page < ActiveRecord::Base
  validates :name, :presence => true
  validates :url_match, :presence => true
  
  belongs_to :category
  
  def self.matching url_match
    where(:url_match => url_match).first
  end
  
  def path
    (category ? category.path : "") + "/" + url_match
  end
end
