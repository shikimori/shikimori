class DbEntriesController < ShikimoriController # rubocop:disable ClassLength
  include FixParamsConcern
  include SearchPhraseConcern

  before_action :authenticate_user!, only: %i[edit edit_field update]

  # it must be always before :fetch_resource
  before_action { og page_title: resource_klass.model_name.human }
  before_action :fetch_resource, if: :resource_id
  before_action :og_db_entry_meta, if: :resource_id

  COLLETIONS_PER_PAGE = 4
  DANGEROUS_ACTION_DELAY_INTERVAL = 30.minutes
  SYNC_EXPIRATION = 4.hours
  POSTER_FIELDS = %i[poster_id poster_data_uri poster_crop_data]

  def tooltip
    og noindex: true
  end

  def collections
    if @resource.collections_scope.none?
      return redirect_to @resource.url, status: :moved_permanently
    end

    og noindex: true, page_title: t('in_collections')

    @collection = Collections::Query.fetch(censored_forbidden?)
      .where(id: @resource.collections_scope)
      .paginate(@page, COLLETIONS_PER_PAGE)
      .lazy_map do |collection|
        Topics::TopicViewFactory
          .new(true, true)
          .build(collection.maybe_topic)
      end
  end

  def edit
    og noindex: true, page_title: i18n_t('entry_edit')

    if json?
      render 'db_entries/versions',
        locals: { collection: @resource.parameterized_versions }
    end
  end

  def edit_field
    og noindex: true, page_title: i18n_t('entry_edit')
    @field = params[:field]

    unless VersionsPolicy.change_allowed? current_user, @resource, @field
      raise CanCan::AccessDenied
    end

    if json?
      render 'db_entries/versions',
        locals: { collection: @resource.parameterized_versions }
    else
      render template: 'db_entries/edit_field'
    end
  end

  def update # rubocop:disable all
    Version.transaction do
      @version =
        if update_params[:poster_data_uri]
          update_poster
        elsif update_params[:image]
          update_poster_old
        elsif update_params[:external_links]
          update_external_links
        else
          update_version
        end

      authorize! :create, @version
    end

    if @version.persisted?
      redirect_to(
        @resource.edit_url,
        notice: i18n_t("version_#{@version.state}")
      )
    else
      redirect_back(
        fallback_location: @resource.edit_url,
        alert: @version.errors[:base]&.dig(0) || i18n_t('no_changes')
      )
    end
  end

  def sync # rubocop:disable Metrics/AbcSize, Merics/MethodLength
    authorize! :sync, resource_klass

    is_anime365 = params[:is_anime365] == '1'
    id = @resource ? @resource.mal_id : params[:db_entry][:mal_id]
    type = resource_klass.base_class.name.downcase

    NamedLogger.sync.info "#{type}##{id} #{'Anime365 ' if is_anime365}User##{current_user.id}"

    Rails.cache.write(
      [type, :"#{:anime365_ if is_anime365}sync", id],
      true,
      expires_in: SYNC_EXPIRATION
    )
    if is_anime365
      SmotretAnime::LinkWorker.perform_async id
    else
      MalParsers::FetchEntry.perform_async id, type
    end

    redirect_back(
      fallback_location: @resource ? @resource.edit_url : moderations_url,
      notice: i18n_t('sync_scheduled')
    )
  end

  def refresh_stats # rubocop:disable Metrics/AbcSize
    authorize! :refresh_stats, resource_klass

    # TODO: extract into sidekiq task?
    # not important right now since access to this method is restricted
    NamedLogger.refresh_stats.info(
      "#{resource_klass.name}##{@resource.id} User##{current_user.id}"
    )

    Animes::RefreshStats.call resource_klass.where(id: @resource.id)
    DbEntry::RefreshScore.call(
      entry: @resource,
      global_average: Animes::GlobalAverage.call(@resource.class.base_class.name)
    )

    redirect_back(
      fallback_location: @resource ? @resource.edit_url : moderations_url,
      notice: i18n_t('refresh_completed')
    )
  end

  def merge_into_other
    authorize! :dangerous_action, resource_klass

    DbEntries::MergeIntoOther.perform_in(
      DANGEROUS_ACTION_DELAY_INTERVAL,
      @resource.object.class.base_class.name,
      @resource.id,
      params[:target_id].to_i,
      current_user.id
    )

    redirect_back(
      fallback_location: @resource.edit_url,
      notice: i18n_t('merge_scheduled')
    )
  end

  def merge_as_episode # rubocop:disable AbcSize
    authorize! :dangerous_action, resource_klass

    DbEntries::MergeAsEpisode.perform_in(
      DANGEROUS_ACTION_DELAY_INTERVAL,
      @resource.object.class.base_class.name,
      @resource.id,
      params[:target_id].to_i,
      params[:as_episode].to_i,
      params[:episode_label],
      params[:episode_field],
      current_user.id
    )

    redirect_back(
      fallback_location: @resource.edit_url,
      notice: i18n_t('merge_scheduled')
    )
  end

  def clear_related_characters
    authorize! :dangerous_action, resource_klass
    NamedLogger.dangerous_action.info 'clear_related_characters  ' \
      "#{@resource.object.class.name}##{@resource.id} User##{current_user.id}"

    @resource.person_roles.where.not(character_id: nil).destroy_all

    redirect_back(
      fallback_location: @resource.edit_url,
      notice: i18n_t('done')
    )
  end

  def clear_related_people
    authorize! :dangerous_action, resource_klass
    NamedLogger.dangerous_action.info 'clear_related_people ' \
      "#{@resource.object.class.name}##{@resource.id} User##{current_user.id}"

    @resource.person_roles.where.not(person_id: nil).destroy_all

    redirect_back(
      fallback_location: @resource.edit_url,
      notice: i18n_t('done')
    )
  end

  def clear_related_titles # rubocop:disable Metrics/AbcSize
    authorize! :dangerous_action, resource_klass
    NamedLogger.dangerous_action.info 'clear_related_titles ' \
      "#{@resource.object.class.name}##{@resource.id} User##{current_user.id}"

    if @resource.anime? || @resource.kinda_manga?
      @resource.related.destroy_all
    else
      @resource.person_roles.where.not(anime_id: nil).destroy_all
      @resource.person_roles.where.not(manga_id: nil).destroy_all
    end

    redirect_back(
      fallback_location: @resource.edit_url,
      notice: i18n_t('done')
    )
  end

  def destroy
    authorize! :destroy, resource_klass

    DbEntries::Destroy.perform_in(
      DANGEROUS_ACTION_DELAY_INTERVAL,
      @resource.object.class.base_class.name,
      @resource.id,
      current_user.id
    )

    redirect_back(
      fallback_location: @resource.edit_url,
      notice: i18n_t('destroy_scheduled')
    )
  end

private

  def og_db_entry_meta # rubocop:disable all
    if @resource.object.respond_to?(:description_ru)
      og description: @resource.description_meta
    end

    if @resource.anime? || @resource.kinda_manga?
      og(
        image: 'http://cdn.anime-recommend.ru/previews' \
          "#{'/manga' if @resource.kinda_manga?}/#{@resource.id}.jpg",
        image_width: 1200,
        image_height: 630,
        image_type: 'image/jpeg',
        twitter_card: 'summary_large_image'
      )
    elsif @resource.poster && @resource.poster.image_data['derivatives']
      og image: ImageUrlGenerator.instance.cdn_poster_url(
        poster: @resource.poster,
        derivative: :main_2x
      )
    end
  end

  def restricted_fields
    @resource.object.class::RESTRICTED_FIELDS.select do |field|
      field != 'image' || @resource.image.exists?
    end
  end

  def update_version
    version = Versioneers::FieldsVersioneer
      .new(@resource.object)
      .premoderate(
        update_params.is_a?(Hash) ? update_params : update_params.to_unsafe_h,
        current_user,
        params[:reason]
      )

    version.auto_accept! if version.persisted? && can?(:auto_accept, version)
    version
  end

  def update_poster
    versioneer = Versioneers::PostersVersioneer.new(@resource.object)
    version = versioneer.premoderate update_params, current_user, params[:reason]
    version.auto_accept! if version.persisted? && can?(:auto_accept, version)
    version
  end

  def update_poster_old
    versioneer = Versioneers::PostersOldVersioneer.new(@resource.object)

    version = versioneer.premoderate(
      update_params[:image],
      current_user,
      params[:reason]
    )

    version.auto_accept! if version.persisted? && can?(:auto_accept, version)
    version
  end

  def update_external_links
    version = Versioneers::CollectionVersioneer
      .new(@resource.object, :external_links)
      .premoderate(
        update_params[:external_links].map(&:to_unsafe_h),
        current_user,
        params[:reason]
      )

    version.auto_accept! if version.persisted? && can?(:auto_accept, version)
    version
  end
end
