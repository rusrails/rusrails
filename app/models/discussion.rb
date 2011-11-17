class Discussion < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true
  belongs_to :author,  :polymorphic => true
  has_many :says

  validates :title, :presence => true, :length => { :maximum => 250 }

  attr_accessible :title, :says_attributes, :subject_id, :subject_type

  accepts_nested_attributes_for :says

  scope :ordered, order("updated_at DESC")
  scope :enabled, where(:enabled=>true).ordered
end
