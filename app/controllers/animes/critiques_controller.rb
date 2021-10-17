# frozen_string_literal: true

class Animes::CritiquesController < AnimesController # rubocop:disable ClassLength
  load_and_authorize_resource

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: [:index]
  skip_before_action :og_meta

  RULES_TOPIC_ID = 299_770

  def index
    @collection = ::Critiques::Query
      .call(@resource.object, {
        locale: locale_from_host,
        id: params[:id].to_i
      })
      .map do |critique|
        topic = critique.maybe_topic locale_from_host
        Topics::CritiqueView.new topic, true, true
      end
  end

  def new
    og page_title: i18n_t('new_critique')
    @rules_topic = Topics::TopicViewFactory.new(false, false).find_by(id: RULES_TOPIC_ID)
  end

  def edit
    og page_title: i18n_t('edit_critique')
  end

  def create
    @critique = Critique::Create.call critique_params, locale_from_host

    if @critique.errors.blank?
      topic = @critique.maybe_topic locale_from_host
      redirect_to(
        UrlGenerator.instance.topic_url(topic),
        notice: i18n_t('critique.created')
      )
    else
      new
      render :new
    end
  end

  def update
    Critique::Update.call @critique, critique_params

    if @critique.errors.blank?
      topic = @critique.maybe_topic locale_from_host
      redirect_to(
        UrlGenerator.instance.topic_url(topic),
        notice: i18n_t('critique.updated')
      )
    else
      edit
      render :edit
    end
  end

  def destroy
    @critique.destroy
    render json: { notice: i18n_t('critique.removed') }
  end

private

  def critique_params
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
      send("#{resource_klass.name.downcase}_critiques_url", @resource)
    )

    if @critique&.persisted? && params[:action] != 'show'
      breadcrumb(
        i18n_t('critique_by', nickname: @critique.user.nickname),
        @critique.url
      )
      @back_url = @critique.url
    else
      @back_url = send("#{resource_klass.name.downcase}_critiques_url", @resource)
    end
  end

  def add_title
    og page_title: i18n_i('Critique', :other)
    if params[:action] == 'show'
      og page_title: i18n_t('critique_by', nickname: @critique.user.nickname)
    end
  end

  def actualize_resource
    if @resource.is_a? Critique
      @critique = @resource.decorate
      @resource = @anime || @manga || @ranobe
    end
  end
end
