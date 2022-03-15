# frozen_string_literal: true

class Animes::ReviewsController < AnimesController
  load_and_authorize_resource except: %i[new]

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: %i[index]
  before_action :existence_check, only: %i[new]

  skip_before_action :og_meta

  PER_PAGE = 8
  PER_PREVIEW = 4

  rescue_from ActiveRecord::RecordNotFound, with: :missing

  def index # rubocop:disable AbcSize, MethodLength
    @opinion = (Types::Review::Opinion[params[:opinion]] if params[:opinion])
    @is_preview = !!params[:is_preview]

    if @opinion
      breadcrumb i18n_i('Review', :other), @resource.reviews_url
      breadcrumb t("animes.reviews.navigation.opinion.#{@opinion}"), nil
    else
      breadcrumb i18n_i('Review', :other), nil
    end

    query = ::Reviews::Query
      .fetch(@resource.object)
      .by_opinion(@opinion)

    query = @is_preview ?
      query.paginate(1, PER_PREVIEW) :
      query.paginate(@page, PER_PAGE)

    @collection = query.transform do |model|
      Topics::ReviewView.new(model.maybe_topic(locale_from_host), true, true)
    end

    if @collection.none? && !request.xhr?
      redirect_to @resource.url, status: :moved_permanently
    end
  end

  def show
    if params[:is_reply]
      og noindex: true, nofollow: true
    else
      ensure_redirect! UrlGenerator.instance.review_url(@review)
    end
    push_js_reply if params[:is_reply]
    breadcrumb "#{i18n_i('Review', :one)} ##{@review.id}", nil

    @topic_view = Topics::ReviewView.new(@review.maybe_topic(locale_from_host), false, false)
  end

  def missing exception
    raise exception if params[:action] != 'show'

    add_breadcrumbs
    breadcrumb "#{i18n_i('Review', :one)} ##{params[:id].to_i}", nil
    og noindex: true, nofollow: true
    render :missing
  end

  def new
    og page_title: i18n_t('new_review')
    breadcrumb i18n_t('new_review'), nil

    @review ||= Review.new do |review|
      review.anime = @anime
      review.manga = @manga || @ranobe
    end

    render :form
  end

  def edit
    og page_title: i18n_t('edit_review')
    breadcrumb i18n_t('edit_review'), nil

    if request.xhr?
      render(
        partial: 'animes/reviews/form',
        locals: {
          review: @review,
          resource: @resource,
          is_remote: true
        }
      )
    else
      render :form
    end
  end

  def create
    @review = Review::Create.call create_params

    if @review.errors.blank?
      redirect_to(
        UrlGenerator.instance.review_url(@review),
        notice: i18n_t('review.created')
      )
    else
      new
    end
  end

  def update
    is_updated = Review::Update.call(
      review: @review,
      params: update_params,
      faye: FayeService.new(current_user, faye_token)
    )

    if is_updated
      redirect_to(
        UrlGenerator.instance.review_url(@review),
        notice: i18n_t('review.updated')
      )
    else
      edit
    end
  end

private

  def create_params
    params
      .require(:review)
      .permit(*Api::V1::ReviewsController::CREATE_PARAMS)
      .merge(user: current_user)
  end

  def update_params
    params
      .require(:review)
      .permit(*Api::V1::ReviewsController::UPDATE_PARAMS)
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
      id: @review.maybe_topic(locale_from_host).id,
      type: :topic,
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
      UrlGenerator.instance.review_url(user_review),
      alert: i18n_t(
        "review_is_already_written.#{(@anime || @manga || @ranobe).object.class.name.downcase}",
        gender: current_user.sex
      )
    )
  end
end
