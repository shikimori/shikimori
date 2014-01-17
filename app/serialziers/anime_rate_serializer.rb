class AnimeRateSerializer < ActiveModel::Serializer
  attributes :id, :score, :status, :episodes, :status_name

  def status_name
    UserRateStatus.get object.status
  end
end
