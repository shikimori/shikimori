class ContestLink < ActiveRecord::Base
  belongs_to :contest
  belongs_to :linked, :polymorphic => true
end
