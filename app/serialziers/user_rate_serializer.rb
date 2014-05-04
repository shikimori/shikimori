class UserRateSerializer < ActiveModel::Serializer
  attributes :id, :score, :status, :status_name, :episodes, :volumes, :chapters, :text, :text_html, :rewatches

  has_one :user
  has_one :target

  def status_name
    UserRateStatus.get object.status
  end
end
