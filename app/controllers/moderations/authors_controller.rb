class Moderations::AuthorsController < ModerationsController
  before_action :check_access!, only: %i[edit update]
  before_action -> { @back_url = params[:back_url] }
  helper_method :collection, :author

  QUERY_SQL = <<~SQL.squish
    select distinct(name)
      from (
        select unnest(%<field>s) as name
          from animes
        ) as t
      where name != ''
      order by name
  SQL

  def show
    og page_title: i18n_t('page_title')
  end

  def edit
    og page_title: 'Редактирование автора'
    og page_title: update_params[:name]
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
  end

  def update
    if update_params.key? :is_verified
      AnimeVideoAuthor
        .find_or_initialize_by(name: update_params[:name])
        .update! is_verified: update_params[:is_verified] == '1'
    end

    if update_params.key?(:new_name) && update_params[:new_name] != update_params[:name]
      1/0
    end

    redirect_to params[:back_url] || moderations_authors_url

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
  end

private

  def check_access!
    authorize! :manage_fansub_authors, Anime
  end

  def collection
    @collection ||= assign_is_verified filter fetch_authors
  end

  def author
    @author ||= AnimeVideoAuthor.find_by name: update_params[:name]
  end

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
  def update_params
    params.require(:author).permit(:name, :new_name, :is_verified)
  end
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
