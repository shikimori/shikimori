class Moderations::AuthorsController < ModerationsController
  before_action :check_access!, only: %i[edit update]
  before_action -> { @back_url = params[:back_url] }
  helper_method :collection, :author, :animes

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
  end

  def update
    if update_params.key? :is_verified
      AnimeVideoAuthor
        .find_or_initialize_by(name: update_params[:name])
        .update! is_verified: update_params[:is_verified] == '1'
    end

    if update_params.key?(:new_name) && update_params[:new_name] != update_params[:name]
      if author
        if new_author
          author.destroy!
        else
          author.update! name: update_params[:new_name]
        end
      end

      animes.each do |anime|
        anime.fansubbers = anime
          .fansubbers
          .map { |v| v.gsub(update_params[:name], update_params[:new_name]) }

        anime.fandubbers = anime
          .fandubbers
          .map { |v| v.gsub(update_params[:name], update_params[:new_name]) }

        anime.save!
      end
    end

    redirect_to params[:back_url] || moderations_authors_url
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

  def new_author
    @new_author ||= AnimeVideoAuthor.find_by name: update_params[:new_name]
  end

  def animes
    @animes = Anime
      .where(
        ':name = ANY(fansubbers) or :name = ANY(fandubbers)',
        name: update_params[:name]
      )
      .order(
        AniMangaQuery.order_sql(
          current_user.preferences.russian_names? ? 'russian' : 'name',
          Anime
        )
      )
      .to_a
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

  def update_params
    params.require(:author).permit(:name, :new_name, :is_verified)
  end
end
