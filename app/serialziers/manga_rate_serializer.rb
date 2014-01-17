class MangaRateSerializer < ActiveModel::Serializer
  attributes :id, :score, :status, :volumes, :chapters, :status_name

  def status_name
    UserRateStatus.get object.status
  end
end
