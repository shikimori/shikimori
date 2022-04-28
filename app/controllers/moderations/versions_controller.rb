class Moderations::VersionsController < ModerationsController
  load_and_authorize_resource except: [:index]
  before_action :set_view, only: %i[index autocomplete_user autocomplete_moderator]

  AUTOCOMPLETE_LIMIT = 10

  def index
    og page_title: i18n_t("content_changes.#{@view.type_param}")
  end

  def show
    og noindex: true

    if @resource.type == ::Versions::RoleVersion.name
      og page_title: t('moderations/roles_controller.page_title')
      breadcrumb(
        t('moderations/roles_controller.page_title'),
        moderations_roles_url
      )
    else
      og page_title: i18n_t('content_changes.all_content')
      breadcrumb(
        i18n_t('content_changes.all_content'),
        moderations_versions_url(type: Moderation::VersionsItemTypeQuery::Types[:content])
      )
    end
    og page_title: i18n_t('content_change', version_id: @resource.id)
  end

  def create
    if @resource.save
      @resource.accept! moderator: current_user if can? :accept, @resource

      redirect_back(
        fallback_location: @resource.item.decorate.url,
        notice: i18n_t("version_#{@resource.state}")
      )
    else
      redirect_back(
        fallback_location: @resource.item.decorate.url,
        alert: @resource.errors.full_messages.join(', ')
      )
    end
  end

  def tooltip
    og noindex: true
  end

  def accept
    transition :accept, 'changes_accepted'
  end

  def take
    transition :take, 'changes_accepted'
  end

  def reject
    transition :reject, 'changes_rejected'
  end

  def accept_taken
    transition :accept_taken, 'changes_accepted'
  end

  def take_accepted
    transition :take_accepted, 'changes_accepted'
  end

  def destroy
    transition :to_deleted, 'changes_deleted'
  end

  def autocomplete_user
    @collection = @view
      .authors_scope(params[:search])
      .order(:nickname)
      .take(AUTOCOMPLETE_LIMIT)
      .to_a

    render 'autocomplete', formats: :json
  end

  def autocomplete_moderator
    @collection = @view
      .moderators_scope(params[:search])
      .order(:nickname)
      .take(AUTOCOMPLETE_LIMIT)
      .to_a

    render 'autocomplete', formats: :json
  end

private

  def create_params
    params
      .require(:version)
      .permit(:type, :item_id, :item_type, :user_id, :reason)
      .to_h
      .merge(item_diff: build_item_diff, state: 'pending')
  end

  def set_view
    @view = VersionsView.new
  end

  def transition action, success_message
    @resource.send(
      :"#{action}!",
      moderator: current_user,
      reason: params[:reason]
    )

    render json: { notice: i18n_t(success_message) }
  rescue StateMachineRollbackError
    render json: @version.errors[:base], status: :unprocessable_entity
  end

  def build_item_diff
    if params[:version][:item_diff].is_a?(String)
      JSON.parse(params[:version][:item_diff], symbolize_names: true)
    else
      params[:version][:item_diff]
    end
  end
end
