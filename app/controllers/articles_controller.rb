class ArticlesController < ShikimoriController
  load_and_authorize_resource :article, except: %i[index]

  before_action { og page_title: i18n_i('Article', :other) }
  before_action :set_breadcrumbs, except: :index
  before_action :resource_redirect, if: :resource_id

  UPDATE_PARAMS = %i[name body state tags]
  CREATE_PARAMS = %i[user_id] + UPDATE_PARAMS

  def index # rubocop:disable AbcSize
    @limit = [[params[:limit].to_i, 4].max, 8].min

    @collection = Articles::Query.fetch(locale_from_host)
      .search(params[:search], locale_from_host)
      .paginate(@page, @limit)
      .lazy_map do |article|
        Topics::TopicViewFactory
          .new(true, true)
          .build(article.maybe_topic(locale_from_host))
      end

    if @page == 1 && params[:search].blank? && user_signed_in?
      @unpublished_articles = current_user.articles.unpublished
    end
  end

  def show
    unless @resource.published?
      raise ActiveRecord::RecordNotFound unless can? :edit, @resource

      breadcrumb @resource.name, edit_article_url(@resource)
      breadcrumb t('actions.preview'), nil
    end

    og page_title: @resource.name
    @topic_view = Topics::TopicViewFactory
      .new(false, false)
      .build(@resource.maybe_topic(locale_from_host))
  end

  def tooltip
    og noindex: true
    @topic_view = Topics::TopicViewFactory
      .new(true, true)
      .build(@resource.maybe_topic(locale_from_host))

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

  def new
    og page_title: i18n_t('new_article')
    render :form
  end

  def create
    @resource = Article::Create.call create_params, locale_from_host

    if @resource.errors.blank?
      redirect_to edit_article_url(@resource),
        notice: i18n_t('article_created')
    else
      new
    end
  end

  def edit
    og page_title: @resource.name
    @section = params[:section]
    render :form
  end

  def update
    Article::Update.call @resource, update_params, current_user

    if @resource.errors.blank?
      redirect_to edit_article_url(@resource), notice: t('changes_saved')
    else
      flash[:alert] = t('changes_not_saved')
      edit
    end
  end

  def destroy
    Article::Destroy.call @resource, current_user

    if request.xhr?
      render json: { notice: i18n_t('article_deleted') }
    else
      redirect_to articles_url, notice: i18n_t('article_deleted')
    end
  end

private

  def set_breadcrumbs
    breadcrumb i18n_i('Article', :other), articles_url

    if %w[edit update].include? params[:action]
      breadcrumb(
        @resource.name,
        @resource.published? ? article_url(@resource) :
          edit_article_url(@resource)
      )
      breadcrumb t('actions.edition'), nil
    end
  end

  def create_params
    article_params CREATE_PARAMS
  end
  alias new_params create_params

  def update_params
    article_params UPDATE_PARAMS
  end

  def article_params permitted_keys
    params
      .require(:article)
      .permit(*permitted_keys)
      .tap do |fixed_params|
        if params[:article][:body].present?
          fixed_params[:body] = Topics::ComposeBody.call(params[:article])
        end

        unless fixed_params[:tags].nil?
          fixed_params[:tags] = fixed_params[:tags].split(',').map(&:strip).select(&:present?)
        end
      end
  end
end
