# frozen_string_literal: true

class Animes::CritiquesController < AnimesController # rubocop:disable ClassLength
  load_and_authorize_resource

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: %i[index]
  skip_before_action :og_meta

  rescue_from ActiveRecord::RecordNotFound, with: :missing

  def index
    breadcrumb i18n_i('Critique', :other), nil
    @collection = ::Critiques::Query
      .call(@resource.object, {
        id: params[:id].to_i
      })
      .map do |critique|
        Topics::CritiqueView.new(critique.maybe_topic, true, true)
      end
  end

  def show
    if params[:is_reply]
      og noindex: true, nofollow: true
    else
      ensure_redirect! UrlGenerator.instance.critique_url(@critique)
    end
    push_js_reply if params[:is_reply]
    breadcrumb "#{i18n_i('Critique', :one)} ##{@critique.id}", nil

    @topic_view = Topics::CritiqueView.new(@critique.maybe_topic, false, false)
  end

  def new
    og page_title: i18n_t('new_critique')
    breadcrumb i18n_t('new_critique'), nil
    render :form
  end

  def edit
    og page_title: i18n_t('edit_critique')
    breadcrumb i18n_t('edit_critique'), nil
    render :form
  end

  def create
    @critique = Critique::Create.call critique_params

    if @critique.errors.blank?
      redirect_to(
        UrlGenerator.instance.critique_url(@critique),
        notice: i18n_t('critique.created')
      )
    else
      new
    end
  end

  def update
    is_updated = Critique::Update.call @critique, critique_params, current_user

    if is_updated
      redirect_to(
        UrlGenerator.instance.critique_url(@critique),
        notice: i18n_t('critique.updated')
      )
    else
      edit
    end
  end

  def missing exception
    raise exception if params[:action] != 'show'

    add_breadcrumbs
    breadcrumb "#{i18n_i('Critique', :one)} ##{params[:id].to_i}", nil
    og noindex: true, nofollow: true
    render :missing
  end

  # it is used in ban messages at least
  def tooltip
    og noindex: true
    return render :missing, status: (xhr_or_json? ? :ok : :not_found) if @resource.is_a? NoTopic

    @topic_view = Topics::CritiqueView.new(@critique.maybe_topic, true, true)

    if request.xhr?
      render(
        partial: 'topics/topic',
        object: @topic_view,
        as: :topic_view,
        layout: false,
        formats: :html
      )
    else
      render :show
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
      id: @critique.maybe_topic.id,
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
