object @resource

child :animes do
  extends 'api/v1/profile/favourites/entry'
end

child :mangas do
  extends 'api/v1/profile/favourites/entry'
end

child :characters do
  extends 'api/v1/profile/favourites/entry'
end

child seyu: :seyu do
  extends 'api/v1/profile/favourites/entry'
end

child mangakas: :mangakas do
  extends 'api/v1/profile/favourites/entry'
end

child producers: :producers do
  extends 'api/v1/profile/favourites/entry'
end

child people: :people do
  extends 'api/v1/profile/favourites/entry'
end
