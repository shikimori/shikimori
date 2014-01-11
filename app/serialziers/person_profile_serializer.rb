class PersonProfileSerializer < PersonSerializer
  include PeopleHelper

  attributes :job_title, :birthday, :website, :producer?, :mangaka?, :seyu?, :groupped_roles
  attribute :roles
  attribute :works

  def roles
    []
  end

  def works
    object.works.map do |work|
      {
        anime: work[:entry].kind_of?(Anime) ? AnimeSerializer.new(work[:entry]) : nil,
        manga: work[:entry].kind_of?(Manga) ? MangaSerializer.new(work[:entry]) : nil,
        role: format_person_role(work[:role], full: true)
      }
    end
  end
end
