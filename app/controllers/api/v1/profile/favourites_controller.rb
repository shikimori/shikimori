class Api::V1::Profile::FavouritesController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/profile/favourites", "List favourites"
  def index
    @resource = OpenStruct.new({
      animes: current_user.fav_animes,
      mangas: current_user.fav_mangas,
      characters: current_user.fav_characters,
      people: current_user.fav_persons,
      mangakas: current_user.fav_mangakas,
      seyu: current_user.fav_seyu,
      producers: current_user.fav_producers
    })
  end
end
