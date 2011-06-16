class Page < ActiveRecord::Base
  validates :name, :presence => true
  validates :url_match, :presence => true, :format => {:without => /(\\|\/)/}
  validate :validates_path
  
  belongs_to :category
  
  scope :ordered, order("show_order DESC",:created_at)
  scope :enabled, where(:enabled=>true).ordered
  
  def self.matching url_match
    where(:url_match => url_match).first
  end
  
  def path
    (category ? category.path : "") + "/" + url_match
  end
  
  def validates_path
    require 'uri'
    uri = URI.parse path
    raise if uri.scheme or uri.host or uri.query
  rescue
    errors.add :url_match
  end
end
