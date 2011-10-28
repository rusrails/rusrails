class Discussion < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true
  belongs_to :author,  :polymorphic => true
  has_many :says

  validates :title, :presence => true, :length => { :maximum => 250 }

  attr_accessible :title, :says_attributes

  accepts_nested_attributes_for :says

  scope :enabled, where(:enabled=>true).order("updated_at DESC")
end
