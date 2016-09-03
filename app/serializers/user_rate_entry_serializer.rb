class UserRateEntrySerializer < ActiveModel::Serializer
  attributes :id, :episodes, :chapters, :volumes

  def episodes
    object.episodes if object.anime?
  end

  def volumes
    object.volumes if object.manga?
  end

  def chapters
    object.chapters if object.manga?
  end
end
