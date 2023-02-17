class Moderations::CollectionsController < ModerationsController
  load_and_authorize_resource
  before_action :set_view, only: %i[index autocomplete_user]

  def index
    og page_title: i18n_t('page_title')
  end

  def accept
    @resource.accept! approver: current_user
    redirect_back fallback_location: moderations_collections_url
  end

  def reject
    @resource.reject! approver: current_user
    redirect_back fallback_location: moderations_collections_url
  end

  def cancel
    @resource.cancel!
    redirect_back fallback_location: moderations_collections_url
  end

  def autocomplete_user
    @collection = @view
      .authors_scope(params[:search])
      .order(:nickname)
      .take(AUTOCOMPLETE_LIMIT)
      .to_a

    render 'moderations/autocomplete', formats: :json
  end

private

  def set_view
    @view = Moderations::CollectionsView.new
  end
end
