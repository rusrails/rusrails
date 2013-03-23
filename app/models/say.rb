class Say < ActiveRecord::Base
  belongs_to :author,  :polymorphic => true
  belongs_to :discussion, :touch => true

  attr_accessible :text

  validates :text, :presence => true

  scope :ordered, order("updated_at DESC")
  scope :enabled, where(:enabled => true)
end
