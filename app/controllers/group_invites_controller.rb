class GroupInvitesController < ShikimoriController
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
    render json: { notice: 'Вы вступили в клуб' }
  end

  def reject
    @resource.reject!
    render nothing: true
  end

private
  def group_invite_params
    params.require(:group_invite).permit([:group_id, :src_id, :dst_id])
  end

  def find_user
    params[:group_invite][:dst_id] = nil if params[:group_invite][:dst_id].blank?
    matched_user = User.find_by nickname: params[:group_invite][:dst_id]
    params[:group_invite][:dst_id] = matched_user.id if matched_user
  end
end
