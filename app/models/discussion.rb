class Discussion < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true
  belongs_to :author,  :polymorphic => true
  has_many :says

  validates :title, :presence => true
end
