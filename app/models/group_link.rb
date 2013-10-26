class GroupLink < ActiveRecord::Base
  belongs_to :group
  belongs_to :linked, :polymorphic => true
end
