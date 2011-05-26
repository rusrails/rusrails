class Category < ActiveRecord::Base
  validates :name, :presence => true
  validates :url_match, :presence => true
  
  has_many :pages
  
  scope :enabled, where(:enabled=>true).order("show_order DESC",:created_at)
  
  def self.matching url_match
    where(:url_match => url_match, :enabled => true).first
  end
  
  def path
    "/"+url_match
  end
end
