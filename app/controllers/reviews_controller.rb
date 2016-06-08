class ReviewsController < AnimesController
  load_and_authorize_resource

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: [:index]

  REVIEWS_CLUB_ID = 293
  ADDITIONAL_TEXT = %r{
    \[spoiler=Рекомендации\]
      (?<text>[\s\S]+)
    \[/spoiler\]
    \s*\Z
  }mix

  # обзоры аниме или манги
  def index
    query = ReviewsQuery.new(
      @resource.object,
      current_user,
      locale_from_domain,
      params[:id].to_i
    )
    @collection = query.fetch
      .map do |review|
        topic = review.maybe_topic locale_from_domain
        Topics::ReviewView.new topic, true, true
      end
  end

  def new
    page_title i18n_t('new_review')
    @additional_text = additinal_text if ru_domain? && I18n.russian?
  end

  def edit
    page_title i18n_t('edit_review')
  end

  def create
    if @review.save
      @review.generate_topics @review.locale

      topic = @review.maybe_topic locale_from_domain
      redirect_to(
        UrlGenerator.instance.topic_url(topic),
        notice: i18n_t('review.created')
      )
    else
      new
      render :new
    end
  end

  def update
    if @review.update update_params
      topic = @review.maybe_topic locale_from_domain
      redirect_to(
        UrlGenerator.instance.topic_url(topic),
        notice: i18n_t('review.updated')
      )
    else
      edit
      render :edit
    end
  end

  def destroy
    @review.destroy
    render json: { notice: i18n_t('review.removed') }
  end

private

  def update_params
    resource_params.except(:locale)
  end

  def resource_params
    params
      .require(:review)
      .permit(:user_id, :target_type, :target_id, :text,
        :storyline, :characters, :animation, :music, :overall)
      .merge(locale: locale_from_domain)
  end

  # url текущего обзора
  #def review_url
    #self.send("#{resource_klass.name.downcase}_review_url", @entry, @review)
  #end

  # тип класса лежит в параметрах
  def resource_klass
    @resource_klass ||= params[:type].constantize
  end

  def resource_id
    @resource_id ||= params[:anime_id] || params[:manga_id]
  end

  def add_breadcrumbs
    breadcrumb(
      i18n_i('Review', :other),
      send("#{resource_klass.name.downcase}_reviews_url", @resource)
    )

    if @review && @review.persisted? && params[:action] != 'show'
      breadcrumb(
        i18n_t('review_by', nickname: @review.user.nickname),
        send("#{resource_klass.name.downcase}_reviews_url", @resource, @review)
      )
      @back_url = send("#{resource_klass.name.downcase}_reviews_url", @resource, @review)
    else
      @back_url = send("#{resource_klass.name.downcase}_reviews_url", @resource)
    end
  end

  def add_title
    page_title i18n_i('Review', :other)
    if params[:action] == 'show'
      page_title i18n_t('review_by', nickname: @review.user.nickname)
    end
  end

  def actualize_resource
    if @resource.kind_of?(Review)
      @review = @resource
      @resource = @anime || @manga
    end
  end

  def additinal_text
    reviews_club = Club.find_by(id: REVIEWS_CLUB_ID)

    Rails.cache.fetch [reviews_club, :guideline] do
      if reviews_club.description =~ ADDITIONAL_TEXT
        text = $LAST_MATCH_INFO[:text]
        BbCodeFormatter.instance.format_description text, reviews_club
      end
    end
  end
end
