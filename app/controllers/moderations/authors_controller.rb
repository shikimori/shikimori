class Moderations::AuthorsController < ModerationsController # rubocop:disable ClassLength
  before_action :check_access!, only: %i[update]
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
    breadcrumb i18n_t('page_title'), moderations_authors_url

    @fansub_animes = Anime
      .where("fansubbers && '{#{Anime.sanitize update_params[:name], true}}'")
      .order(order_sql)

    @fandub_animes = Anime
      .where("fandubbers && '{#{Anime.sanitize update_params[:name], true}}'")
      .order(order_sql)
  end

  def update # rubocop:disable all
    if update_params.key? :is_verified
      AnimeVideoAuthor
        .find_or_initialize_by(name: update_params[:name])
        .update!(
          is_verified: update_params[:is_verified] == '1' || update_params[:is_verified] == 'true'
        )
    end

    if update_params.key?(:new_name) && update_params[:new_name] != update_params[:name]
      if author
        if new_author || update_params[:new_name].blank?
          author.destroy!
        else
          author.update! name: update_params[:new_name]
        end
      end

      animes.each do |anime|
        anime.fansubbers = anime
          .fansubbers
          .map { |v| v == update_params[:name] ? update_params[:new_name] : v }
          .select(&:present?)
          .uniq

        anime.fandubbers = anime
          .fandubbers
          .map { |v| v == update_params[:name] ? update_params[:new_name] : v }
          .select(&:present?)
          .uniq

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
    @collection ||= filter_verified assign_is_verified filter fetch_authors
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
      .order(order_sql)
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

  def filter_verified collection
    if params[:is_verified] == 'true'
      collection = collection.select(&:is_verified)
    end
    if params[:is_verified] == 'false'
      collection = collection.reject(&:is_verified)
    end
    collection
  end

  def order_sql
    Animes::Filters::OrderBy.arel_sql(
      term: current_user.preferences.russian_names? ? :russian : :name,
      scope: Anime
    )
  end

  def update_params
    params.require(:author).permit(:name, :new_name, :is_verified)
  end
end
