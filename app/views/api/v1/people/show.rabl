object @resource

extends 'api/v1/people/preview'

attributes :job_title, :birthday, :website, :producer?, :mangaka?, :seyu?, :groupped_roles

if @resource.kind_of? SeyuDecorator
  node :roles do |person|
    person.works.map do |work|
      {
        characters: partial("api/v1/characters/preview", object: work[:characters]),
        animes: partial("api/v1/animes/preview", object: work[:animes])
      }
    end
  end
  node(:works) { [] }
else
  node(:roles) { [] }
  node :works do |person|
    person.works.map do |work|
      {
        anime: work[:entry].kind_of?(Anime) ? partial("api/v1/animes/preview", object: work[:entry]) : nil,
        manga: work[:entry].kind_of?(Manga) ? partial("api/v1/mangas/preview", object: work[:entry]) : nil,
        role: format_person_role(work[:role], full: true)
      }
    end
  end
end
