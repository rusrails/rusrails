class Category < ActiveRecord::Base
  validates :name, :presence => true
  validates :url_match, :presence => true
  
  has_many :pages
  
  scope :ordered, order("show_order DESC",:created_at)
  scope :enabled, where(:enabled=>true).ordered
  
  def self.matching url_match
    where(:url_match => url_match, :enabled => true).first
  end
  
  def path
    "/"+url_match
  end
end
