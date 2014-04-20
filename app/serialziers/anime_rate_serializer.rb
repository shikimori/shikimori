class AnimeRateSerializer < ActiveModel::Serializer
  attributes :id, :score, :status, :episodes, :status_name, :anime, :notice, :notice_html

  def status_name
    UserRateStatus.get object.status
  end

  def anime
    AnimeSerializer.new object.anime
  end
end
