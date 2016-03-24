class ReviewsController < AnimesController
  load_and_authorize_resource

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: [:index]

  # обзоры аниме или манги
  def index
    @collection = ReviewsQuery
      .new(@resource.object, current_user, params[:id].to_i)
      .fetch
      .map { |review| Topics::ReviewView.new review.topic, true, true }
  end

  def new
    page_title i18n_t('new_review')
  end

  def edit
    page_title i18n_t('edit_review')
  end

  def create
    if @review.save
      redirect_to(
        UrlGenerator.instance.topic_url(@review.topic),
        notice: i18n_t('review.created')
      )
    else
      new
      render :new
    end
  end

  def update
    if @review.update review_params
      redirect_to(
        UrlGenerator.instance.topic_url(@review.topic),
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

  def review_params
    params
      .require(:review)
      .permit :user_id, :target_type, :target_id, :text,
        :storyline, :characters, :animation, :music, :overall
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
end
