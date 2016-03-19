class PersonProfileSerializer < PersonSerializer
  attributes :japanese, :job_title, :birthday, :website, :groupped_roles,
    :roles, :works, :thread_id,
    :person_favoured?,
    :producer?, :producer_favoured?,
    :mangaka?, :mangaka_favoured?,
    :seyu?, :seyu_favoured?,
    :updated_at

  def roles
    []
  end

  def works
    object.works.map do |work|
      {
        anime: work.object.kind_of?(Anime) ? AnimeSerializer.new(work) : nil,
        manga: work.object.kind_of?(Manga) ? MangaSerializer.new(work) : nil,
        role: work.formatted_role
      }
    end
  end

  def thread_id
    object.topic.try :id
  end
end
