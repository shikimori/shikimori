class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true

  validates_presence_of :user
  validates_presence_of :target
end
