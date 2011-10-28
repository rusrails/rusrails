class Say < ActiveRecord::Base
  belongs_to :author,  :polymorphic => true
  belongs_to :discussion

  attr_accessible :text

  validates :text, :presence => true

  scope :enabled, where(:enabled=>true)
end
