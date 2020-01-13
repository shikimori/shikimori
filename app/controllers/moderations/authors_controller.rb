class Moderations::AuthorsController < ModerationsController
  # load_and_authorize_resource

  QUERY_SQL = <<~SQL.squish
    select distinct(name)
      from (
        select unnest(%<field>s) as name
          from animes
        ) as t
      order by name
  SQL

  def index
    og page_title: i18n_t('page_title')
    @collection = assign_is_verified filter fetch_authors
  end

  # def edit
  #   og page_title: "Редактирование автора ##{@resource.id}"
  #   og page_title: @resource.name
  #   @back_url = moderations_anime_video_authors_url
  #   breadcrumb i18n_t('page_title'), @back_url
  #
  #   @scope = @resource.anime_videos
  #     .order(:episode, :kind, :id)
  #     .includes(:anime)
  #
  #   if params[:anime_id].present?
  #     @anime = Anime.find params[:anime_id]
  #     @scope.where! anime_id: params[:anime_id]
  #   end
  #
  #   @scope.where! kind: params[:kind] if params[:kind].present?
  # end
  #
  # def update
  #   if update_params.key? :is_verified
  #     @resource.update is_verified: update_params[:is_verified]
  #   end
  #
  #   if update_params.key? :name
  #     rename_author
  #
  #     if @resource.persisted?
  #       redirect_to edit_moderations_anime_video_author_url(@resource)
  #     else
  #       redirect_to moderations_anime_video_authors_url
  #     end
  #   else
  #     redirect_back fallback_location: moderations_anime_video_authors_url
  #   end
  # end

private

  def fetch_authors
    Anime
      .connection
      .execute(
        format(QUERY_SQL, field: params[:fansub] ? 'fansubbers' : 'fandubbers')
      )
      .sort_by { |v| v['name'] }
      .map { |v| build v }
  end

  def build entry
    OpenStruct.new(
      name: entry['name'],
      search_name: entry['name'].downcase,
      is_verified: false
    )
  end

  def filter collection
    if params[:search].present?
      collection = collection
        .select { |v| v.search_name.include? params[:search].downcase }
    end

    collection
  end

  def assign_is_verified collection
    anime_video_authors = AnimeVideoAuthor
      .where(name: collection.map(&:name))

    collection.each do |author|
      author.is_verified = anime_video_authors
        .find { |v| v.name == author.name }
        &.is_verified || false
    end
  end

  # def rename_author
  #   if params[:anime_id].present? || params[:kind].present?
  #     AnimeVideoAuthor::SplitRename.call(
  #       model: @resource,
  #       new_name: update_params[:name],
  #       anime_id: (params[:anime_id] if params[:anime_id].present?),
  #       kind: (params[:kind] if params[:kind].present?)
  #     )
  #   else
  #     AnimeVideoAuthor::Rename.call @resource, update_params[:name]
  #   end
  # end
  #
  # def update_params
  #   params.require(:anime_video_author).permit(:name, :is_verified, :anime_id)
  # end
  #
  # def filter_authors anime
  #   scope = anime.anime_videos
  #   scope = scope.available if params[:broken_videos] == 'false'
  #
  #   scope
  #     .except(:order)
  #     .distinct
  #     .pluck(:anime_video_author_id)
  #     .compact
  # end
  #
  # def videos_scope
  #   if params[:broken_videos] == 'false'
  #     AnimeVideo.available
  #   else
  #     AnimeVideo.all
  #   end
  # end
  #
  # def cache_key
  #   [
  #     :anime_video_authors,
  #     AnimeVideoAuthor.order(:updated_at).last.updated_at,
  #     AnimeVideoAuthor.last.id,
  #     AnimeVideoAuthor.count,
  #     params[:anime_id]
  #   ]
  # end
end
