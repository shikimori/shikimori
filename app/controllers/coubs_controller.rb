class CoubsController < ShikimoriController
  def index
    anime = Anime.find params[:id]

    @results = Coubs::Fetch.call(
      tags: anime.coub_tags,
      iterator: Encryptor.instance.decrypt(params[:iterator])
    )
  end

  def autocomplete
    cache_key = [:autocomplete, :coub_tags, params[:search]]

    @collection =
      Rails.cache.fetch cache_key, expires_in: 1.month do
        CoubTagsQuery.new(params[:search]).complete
      end
  end
end
