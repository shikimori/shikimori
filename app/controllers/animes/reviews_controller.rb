# frozen_string_literal: true

class Animes::ReviewsController < AnimesController
  load_and_authorize_resource

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: [:index]
  skip_before_action :og_meta

  # RULES_TOPIC_ID = 299_770

  def index
    query = ::Reviews::Query.new(
      @resource.object,
      current_user,
      locale_from_host,
      params[:id].to_i
    )
    @collection = query.fetch
      .map do |review|
        topic = review.maybe_topic locale_from_host
        Topics::ReviewView.new topic, true, true
      end
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
    breadcrumb(
      i18n_i('Review', :other),
      send("#{resource_klass.name.downcase}_reviews_url", @resource)
    )

    if @review&.persisted? && params[:action] != 'show'
      breadcrumb(
        i18n_t('review_by', nickname: @review.user.nickname),
        @review.url
      )
      @back_url = @review.url
    else
      @back_url = send("#{resource_klass.name.downcase}_reviews_url", @resource)
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
      @review = @resource.decorate
      @resource = @anime || @manga || @ranobe
    end
  end
end
