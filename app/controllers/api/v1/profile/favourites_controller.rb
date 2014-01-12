class Api::V1::Profile::FavouritesController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/profile/favourites", "List favourites"
  def index
    favourites = Rails.cache.fetch [current_user, :favourites] do
      {
        animes: current_user.fav_animes.all,
        mangas: current_user.fav_mangas.all,
        characters: current_user.fav_characters.all,
        people: current_user.fav_persons.all,
        mangakas: current_user.fav_mangakas.all,
        seyu: current_user.fav_seyu.all,
        producers: current_user.fav_producers.all
      }
    end
    @resource = OpenStruct.new favourites
  end
end
