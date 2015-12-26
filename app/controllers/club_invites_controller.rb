class ClubInvitesController < ShikimoriController
  before_action :find_user, only: :create
  load_and_authorize_resource

  def create
    if @resource.save
      render json: { notice: 'Приглашение отправлено' }
    else
      render json: @resource.errors.full_messages, status: :unprocessable_entity
    end
  end

  def accept
    @resource.accept!
    render json: { notice: 'Приглашение принято' }
  end

  def reject
    @resource.reject!
    render json: { notice: 'Приглашение отклонено' }
  end

private

  def club_invite_params
    params.require(:club_invite).permit([:club_id, :src_id, :dst_id])
  end

  def find_user
    params[:club_invite][:dst_id] = nil if params[:club_invite][:dst_id].blank?
    matched_user = User.find_by nickname: params[:club_invite][:dst_id]
    params[:club_invite][:dst_id] = matched_user.id if matched_user
  end
end
