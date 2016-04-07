class AnimeVideoReportSerializer < ActiveModel::Serializer
  attributes :id, :kind, :state, :message, :created_at

  has_one :anime_video
  has_one :user
  has_one :approver
end
