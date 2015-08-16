class Moderation::VersionsController < ShikimoriController
  load_and_authorize_resource

  page_title i18n_t('content_changes')

  def show
    noindex
    page_title i18n_t('content_change', version_id: @resource.id, author: @resource.user.nickname)
  end

  def tooltip
    noindex
  end

  def index
    @versions = VersionsView.new
  end

  # применение предложенного пользователем изменения
  def accept
    transition :accept, 'changes_accepted'
  end

  def take
    transition :take, 'changes_accepted'
  end

  def reject
    transition :reject, 'changes_rejected'
  end

  def destroy
    transition :to_deleted, 'changes_deleted'
  end

private

  def transition action, success_message
    @resource.send action, current_user, params[:reason]
    redirect_to_back_or_to moderation_versions_url, notice: i18n_t(success_message)

  rescue StateMachine::InvalidTransition
    redirect_to_back_or_to moderation_versions_url, alert: i18n_t('changes_failed')
  end
end
