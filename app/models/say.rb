class Say < ActiveRecord::Base
  belongs_to :author,  :polymorphic => true
  belongs_to :discussion
end
