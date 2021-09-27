# frozen_string_literal: true

class Animes::ReviewsController < AnimesController
  load_and_authorize_resource

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs

  skip_before_action :og_meta

  # RULES_TOPIC_ID = 299_770
  PER_PAGE = 8
  PER_PREVIEW = 4

  def index
    @opinion = (Types::Review::Opinion[params[:opinion]] if params[:opinion])
    @is_preview = !!params[:is_preview]

    query = ::Reviews::Query
      .fetch(@resource.object)
      .by_opinion(@opinion)

    @collection = @is_preview ?
      query.paginate(1, PER_PREVIEW) :
      query.paginate(@page, PER_PAGE)
  end

  def show
  end

  # def new
  #   og page_title: i18n_t('new_review')
  #   @rules_topic = Topics::TopicViewFactory.new(false, false).find_by(id: RULES_TOPIC_ID)
  # end

  # def edit
  #   og page_title: i18n_t('edit_review')
  # end

private

  # тип класса лежит в параметрах
  def resource_klass
    @resource_klass ||= params[:type].constantize
  end

  def resource_id
    @resource_id ||= params[:anime_id] || params[:manga_id] ||
      params[:ranobe_id]
  end

  def add_breadcrumbs
    if params[:action] == 'show'
      breadcrumb i18n_i('Review', :other), @resource.reviews_url
      @back_url = @resource.reviews_url
    else
      breadcrumb i18n_i('Review', :other), nil
    end
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
end
