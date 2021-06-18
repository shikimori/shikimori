class TopicViewing < ApplicationRecord
  belongs_to :user
  belongs_to :viewed,
    class_name: 'Topic',
    inverse_of: :viewings
end
