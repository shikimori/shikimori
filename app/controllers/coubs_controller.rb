class CoubsController < ShikimoriController
  before_action :validate_iterator, only: %i[index]

  def index
    @anime = Anime.find params[:id]

    @results = Coubs::Fetch.call(
      tags: @anime.coub_tags,
      iterator: params[:iterator]
    )
  end

  def autocomplete
    cache_key = [:autocomplete, :coub_tags, params[:search]]

    @collection =
      Rails.cache.fetch cache_key, expires_in: 1.month do
        CoubTagsQuery.new(params[:search]).complete
      end
  end

private

  def validate_iterator
    head 404 unless Encoder.instance.valid? text: params[:iterator], hash: params[:checksum]
  end
end
