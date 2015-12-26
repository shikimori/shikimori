class TopicIgnore < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic, class_name: Entry.name

  validates :user, :topic, presence: true
end
