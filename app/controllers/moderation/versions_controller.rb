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
    @resource.accept current_user
    redirect_to_back_or_to moderation_versions_url, notice: i18n_t('changes_accepted')
  end

  def take
    @resource.take current_user
    redirect_to_back_or_to moderation_versions_url, notice: i18n_t('changes_accepted')
  end

  def reject
    @resource.reject current_user, params[:reason]
    redirect_to_back_or_to moderation_versions_url, notice: i18n_t('changes_rejected')
  end

  def destroy
    @resource.to_deleted current_user
    redirect_to_back_or_to moderation_versions_url, notice: i18n_t('changes_deleted')
  end
end
