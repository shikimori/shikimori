class TopicIgnore < ApplicationRecord
  include AntispamConcern

  antispam(
    per_day: 300,
    user_id_key: :user_id
  )

  belongs_to :user
  belongs_to :topic
end
