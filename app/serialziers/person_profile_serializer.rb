class PersonProfileSerializer < PersonSerializer
  attributes :job_title, :birthday, :website, :groupped_roles
  attribute :roles
  attribute :works
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
        anime: work[:entry].kind_of?(Anime) ? AnimeSerializer.new(work[:entry]) : nil,
        manga: work[:entry].kind_of?(Manga) ? MangaSerializer.new(work[:entry]) : nil,
        role: work.formatted_role
      }
    end
  end
end
