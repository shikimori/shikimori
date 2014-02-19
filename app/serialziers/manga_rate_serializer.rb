class MangaRateSerializer < ActiveModel::Serializer
  attributes :id, :score, :status, :volumes, :chapters, :status_name, :manga

  def status_name
    UserRateStatus.get object.status
  end

  def manga
    MangaSerializer.new object.manga
  end
end
