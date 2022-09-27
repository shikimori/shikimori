class ClubInvitesController < ShikimoriController
  before_action :find_user, only: :create
  load_and_authorize_resource

  def create
    @resource.destroy! if @resource.save && @resource.club.shadowbanned?
    render json: { notice: i18n_t('invitation_sent') }
  end

  def accept
    @resource.accept!
    render json: { notice: i18n_t('invitation_accepted') }
  end

  def reject
    @resource.close!
    render json: { notice: i18n_t('invitation_rejected') }
  end

private

  def club_invite_params
    params.require(:club_invite).permit(%i[club_id src_id dst_id])
  end

  def find_user
    params[:club_invite][:dst_id] = nil if params[:club_invite][:dst_id].blank?
    matched_user = User.find_by nickname: params[:club_invite][:dst_id]
    params[:club_invite][:dst_id] = matched_user.id if matched_user
  end
end
