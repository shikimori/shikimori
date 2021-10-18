# frozen_string_literal: true

class Animes::ReviewsController < AnimesController
  load_and_authorize_resource except: %i[new]

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: %i[index]

  skip_before_action :og_meta

  RULES_TOPIC_ID = 356_281
  PER_PAGE = 8
  PER_PREVIEW = 4

  def index # rubocop:disable AbcSize
    breadcrumb i18n_i('Review', :other), nil
    @opinion = (Types::Review::Opinion[params[:opinion]] if params[:opinion])
    @is_preview = !!params[:is_preview]

    query = ::Reviews::Query
      .fetch(@resource.object)
      .by_opinion(@opinion)

    @collection = @is_preview ?
      query.paginate(1, PER_PREVIEW) :
      query.paginate(@page, PER_PAGE)

    if @collection.none? && !request.xhr?
      redirect_to @resource.url, status: :moved_permanently
    end
  end

  def show
    push_js_reply if params[:is_reply]
  end

  def new
    og page_title: i18n_t('new_review')

    @review ||= Review.new do |review|
      review.anime = @anime
      review.manga = @manga || @ranobe
    end

    @rules_topic = Topics::TopicViewFactory
      .new(false, false)
      .find_by(id: RULES_TOPIC_ID)
  end

  def create
    @review = Review::Create.call review_params

    if @review.errors.blank?
      redirect_to UrlGenerator.instance.review_url(@review)
    else
      new
      render :new
    end
  end

  # def edit
  #   og page_title: i18n_t('edit_review')
  #   @back_url = UrlGenerator.instance.review_url(@review, is_canonical: true)
  #   breadcrumb "#{i18n_i 'Review', :one} ##{@review.id}", @back_url
  # end

private

  def review_params
    params
      .require(:review)
      .permit(:body, :anime_id, :manga_id, :opinion)
      .merge(user: current_user)
  end

  def add_breadcrumbs
    @back_url = @resource.reviews_url
    breadcrumb i18n_i('Review', :other), @back_url
  end

  # тип класса лежит в параметрах
  def resource_klass
    @resource_klass ||= params[:type].constantize
  end

  def resource_id
    @resource_id ||= params[:anime_id] || params[:manga_id] ||
      params[:ranobe_id]
  end

  def add_title
    og page_title: i18n_i('Review', :other)

    if params[:action] == 'show'

      og page_title: i18n_t('review_by', nickname: @review.user.nickname)
    end
  end

  def actualize_resource
    if @resource.is_a? Review
      @review = @resource
      @resource = @anime || @manga || @ranobe
    end
  end

  def push_js_reply
    gon.push reply: {
      id: @review.id,
      type: :review,
      userId: @review.user_id,
      nickname: @review.user.nickname,
      text: @review.user.nickname,
      url: UrlGenerator.instance.review_url(@review)
    }
  end
end
