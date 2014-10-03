class GroupInvitesController < ShikimoriController
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
end
