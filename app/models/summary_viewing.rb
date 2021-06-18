class SummaryViewing < ApplicationRecord
  belongs_to :user
  belongs_to :viewed, class_name: Summary.name, foreign_key: :viewed_id
end
