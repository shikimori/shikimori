class SummaryViewing < ApplicationRecord
  belongs_to :user
  belongs_to :viewed,
    class_name: 'Summary',
    inverse_of: :viewings
end
