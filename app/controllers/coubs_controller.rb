class CoubsController < ShikimoriController
  def index
    anime = Anime.find params[:id]

    @results = Coubs::Fetch.call anime.coub_tags, params[:iterator]
  end

  def autocomplete
    @collection = CoubTagsQuery.new(params[:search]).complete
  end
end
