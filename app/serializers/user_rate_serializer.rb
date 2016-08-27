class UserRateSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :target_id, :target_type, :score, :status,
    :rewatches, :episodes, :volumes, :chapters, :text, :text_html,
    :created_at, :updated_at
end
