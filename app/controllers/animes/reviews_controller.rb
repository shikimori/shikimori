# frozen_string_literal: true

class Animes::ReviewsController < AnimesController
  load_and_authorize_resource except: %i[new]

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: %i[index]
  before_action :existence_check, only: %i[new]

  skip_before_action :og_meta

  RULES_TOPIC_ID = 356_281
  PER_PAGE = 8
  PER_PREVIEW = 4

  def index # rubocop:disable AbcSize, MethodLength
    breadcrumb i18n_i('Review', :other), nil
    @opinion = (Types::Review::Opinion[params[:opinion]] if params[:opinion])
    @is_preview = !!params[:is_preview]

    query = ::Reviews::Query
      .fetch(@resource.object)
      .by_opinion(@opinion)

    query = @is_preview ?
      query.paginate(1, PER_PREVIEW) :
      query.paginate(@page, PER_PAGE)

    @collection = query.transform do |model|
      Topics::TopicViewFactory
        .new(true, true)
        .build(model.maybe_topic(locale_from_host))
    end

    if @collection.none? && !request.xhr?
      redirect_to @resource.url, status: :moved_permanently
    end
  end

  def show
    ensure_redirect!(
      params[:is_reply] ?
        UrlGenerator.instance.reply_review_url(@review) :
        UrlGenerator.instance.review_url(@review, is_canonical: true)
    )
    push_js_reply if params[:is_reply]

    @topic_view = Topics::TopicViewFactory
      .new(false, false)
      .build(@resource.maybe_topic(locale_from_host))
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

  def existence_check
    user_review = Review.find_by(
      user: current_user,
      anime: @anime,
      manga: @manga || @ranobe
    )
    return unless user_review

    redirect_to(
      UrlGenerator.instance.review_url(user_review, is_canonical: true),
      alert: i18n_t(
        "review_is_already_written.#{(@anime || @manga || @ranobe).object.class.name.downcase}",
        gender: current_user.sex
      )
    )
  end
end
