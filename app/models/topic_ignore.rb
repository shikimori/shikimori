class TopicIgnore < ApplicationRecord
  belongs_to :user
  belongs_to :topic

  validates :user, :topic, presence: true
end
