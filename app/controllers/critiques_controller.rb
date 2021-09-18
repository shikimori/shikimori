# frozen_string_literal: true

class CritiquesController < AnimesController # rubocop:disable ClassLength
  load_and_authorize_resource

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: [:index]
  skip_before_action :og_meta

  RULES_TOPIC_ID = 299_770

  # обзоры аниме или манги
  def index
    query = Critiques::Query.new(
      @resource.object,
      current_user,
      locale_from_host,
      params[:id].to_i
    )
    @collection = query.fetch
      .map do |review|
        topic = review.maybe_topic locale_from_host
        Topics::CritiqueView.new topic, true, true
      end
  end

  def new
    og page_title: i18n_t('new_review')
    @rules_topic = Topics::TopicViewFactory.new(false, false).find_by(id: RULES_TOPIC_ID)
  end

  def edit
    og page_title: i18n_t('edit_review')
  end

  def create
    @review = Critique::Create.call resource_params, locale_from_host

    if @review.errors.blank?
      topic = @review.maybe_topic locale_from_host
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
    Critique::Update.call @review, resource_params

    if @review.errors.blank?
      topic = @review.maybe_topic locale_from_host
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

  def resource_params
    params
      .require(:critique)
      .permit(
        :user_id,
        :target_type,
        :target_id,
        :text,
        :storyline,
        :characters,
        :animation,
        :music,
        :overall
      )
  end

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
      i18n_i('Critique', :other),
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
    og page_title: i18n_i('Critique', :other)
    og page_title: i18n_t('review_by', nickname: @review.user.nickname) if params[:action] == 'show'
  end

  def actualize_resource
    if @resource.is_a? Critique
      @review = @resource.decorate
      @resource = @anime || @manga || @ranobe
    end
  end
end
