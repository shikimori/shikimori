# frozen_string_literal: true

class Animes::CritiquesController < AnimesController # rubocop:disable ClassLength
  load_and_authorize_resource

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: %i[index]
  skip_before_action :og_meta

  def index
    breadcrumb i18n_i('Critique', :other), nil
    @collection = ::Critiques::Query
      .call(@resource.object, {
        locale: locale_from_host,
        id: params[:id].to_i
      })
      .map do |critique|
        Topics::CritiqueView.new(critique.maybe_topic(locale_from_host), true, true)
      end
  end

  def show
    ensure_redirect!(
      params[:is_reply] ?
        UrlGenerator.instance.reply_critique_url(@critique) :
        UrlGenerator.instance.critique_url(@critique)
    )
    push_js_reply if params[:is_reply]

    @topic_view = Topics::CritiqueView.new(@critique.maybe_topic(locale_from_host), false, false)
  end

  def new
    og page_title: i18n_t('new_critique')
    render :form
  end

  def edit
    og page_title: i18n_t('edit_critique')
    render :form
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
    end
  end

  def update
    is_updated = Critique::Update.call @critique, critique_params, current_user

    if is_updated
      topic = @critique.maybe_topic locale_from_host
      redirect_to(
        UrlGenerator.instance.topic_url(topic),
        notice: i18n_t('critique.updated')
      )
    else
      edit
    end
  end

  def destroy
    Critique::Destroy.call @critique, current_user
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

  def push_js_reply
    gon.push reply: {
      id: @critique.maybe_topic(locale_from_host).id,
      type: :topic,
      userId: @critique.user_id,
      nickname: @critique.user.nickname,
      text: @critique.user.nickname,
      url: UrlGenerator.instance.critique_url(@critique)
    }
  end

  def actualize_resource
    if @resource.is_a? Critique
      @critique = @resource.decorate
      @resource = @anime || @manga || @ranobe
    end
  end
end
