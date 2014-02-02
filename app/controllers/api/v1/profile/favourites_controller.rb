class Api::V1::Profile::FavouritesController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/profile/favourites", "List favourites"
  def index
    favourites = Rails.cache.fetch [current_user, :favourites] do
      {
        animes: current_user.fav_animes.to_a,
        mangas: current_user.fav_mangas.to_a,
        characters: current_user.fav_characters.to_a,
        people: current_user.fav_persons.to_a,
        mangakas: current_user.fav_mangakas.to_a,
        seyu: current_user.fav_seyu.to_a,
        producers: current_user.fav_producers.to_a
      }
    end
    @resource = OpenStruct.new favourites
  end
end
