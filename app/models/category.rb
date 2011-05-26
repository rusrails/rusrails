class Category < ActiveRecord::Base
  validates :name, :presence => true
  validates :url_match, :presence => true
  
  has_many :pages
  
  scope :enabled, where(:enabled=>true)
  
  def path
    "/"+url_match
  end
end
