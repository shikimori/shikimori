class ContestLink < ApplicationRecord
  belongs_to :contest
  belongs_to :linked, polymorphic: true
end
