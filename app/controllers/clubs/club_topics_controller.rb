class Clubs::ClubTopicsController < ClubsController
  load_and_authorize_resource class: Topic.name, except: %i[index]
  # because it is disabled for index action in clubs controller
  authorize_resource :club, only: %i[club]

  before_action { og page_title: i18n_i('Club', :other) }
  before_action :prepare_club

  def index
    @forums_view = Forums::View.new 'clubs',
      linked: @club.object,
      linked_forum: true
    ensure_redirect! @forums_view.current_page_url
  end

  def show
    ensure_redirect! UrlGenerator.instance.topic_url(@resource)

    og page_title: @resource.title
    @topic_view = Topics::TopicViewFactory.new(false, false).build @resource
  end

  def new
    og page_title: i18n_t('new.title')
    render 'form'
  end

  def create
    @resource = Topic::Create.call(
      faye: faye,
      params: create_params,
      locale: locale_from_host
    )

    if @resource.persisted?
      redirect_to(
        UrlGenerator.instance.topic_url(@resource),
        notice: i18n_t('topic.created')
      )
    else
      flash[:alert] = t('changes_not_saved')
      new
    end
  end

private

  def prepare_club # rubocop:disable AbcSize
    @club = @club.decorate

    breadcrumb i18n_i('Club', :other), clubs_url
    breadcrumb @club.name, club_url(@club)
    og page_title: @club.name

    unless params[:action] == 'index'
      @back_url = club_club_topics_url(@club)
      breadcrumb i18n_i('Topic', :other), club_club_topics_url(@club)
    end

    @back_url = @club.url if %w[index show].include? params[:action]

    og page_title: i18n_i('Topic', :other)
  end

  def create_params
    params.require(:topic).permit(*TopicsController::CREATE_PARAMS)
  end
  alias new_params create_params

  def update_params
    params.require(:topic).permit(*TopicsController::UPDATE_PARAMS)
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
