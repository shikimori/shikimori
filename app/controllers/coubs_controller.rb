class CoubsController < ShikimoriController
  def index
    anime = Anime.find params[:id]

    @results = Coubs::Fetch.call(
      tags: anime.coub_tags,
      iterator: params[:iterator]
    )
  end

  def autocomplete
    @collection = CoubTagsQuery.new(params[:search]).complete
  end
end
