class PersonProfileSerializer < PersonSerializer
  attributes :japanese, :job_title, :birthday, :website, :groupped_roles
  attributes :roles, :works, :thread_id
  attributes :person_favoured?
  attributes :producer?, :producer_favoured?
  attributes :mangaka?, :mangaka_favoured?
  attributes :seyu?, :seyu_favoured?

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
    object.thread.try :id
  end
end
