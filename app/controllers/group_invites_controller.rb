class GroupInvitesController < ShikimoriController
  load_and_authorize_resource
  #before_filter :authenticate_user!

  def create
    #@group = Group.find(params[:group_id])
    #@user = User.find_by_nickname(params[:nickname])
    #unless @user
      #render json: ['Указан несуществующий пользователь'], status: :unprocessable_entity
      #return
    #end
    #raise Forbidden unless @group.has_member?(current_user)

    #if @group.banned?(@user)
      #render json: [I18n.t('activerecord.errors.models.group_invites.user_is_banned')], status: :unprocessable_entity
      #return
    #end

    #if @group.has_member?(current_user) && @group.has_member?(@user)
      #render json: ['%s уже находится в этой группе' % @user.nickname], status: :unprocessable_entity
      #return
    #end

    #GroupInvite.create!(
      #group: @group,
      #src: current_user,
      #dst: @user,
      #status: GroupInviteStatus::Pending
    #)
    #render json: { notice: 'Отправлено приглашение для %s' % @user.nickname }
  #rescue ActiveRecord::RecordNotUnique
    #render json: ['У %s уже есть приглашение в этот клуб' % params[:nickname]], status: :unprocessable_entity
    if @resource.save
      render json: { notice: "Отправлено приглашение для #{@resource.dst.nickname}" }
    else
      render json: @resource.errors.full_messages, status: :unprocessable_entity
    end
  end

  # принятие приглашения на вступление в группу
  def accept
    #if check_credentials
      #if @invite.group.banned?(current_user)
        #render json: [I18n.t('activerecord.errors.models.group_invites.you_are_banned')], status: :unprocessable_entity
        #return
      #end

      #@invite.group.join current_user
      #render json: {
        #notice: 'Вы вступили в %s' % @invite.group.name
      #}
    #else
      #render json: {}
    #end
  end

  # отказ от приглашения на вступление в группу
  def reject
    #if check_credentials
      #@invite.update_attribute :status, GroupInviteStatus::Rejected
    #end
    #render json: {}
  end

private
  #def check_credentials
    #@invite = GroupInvite.find(params[:id])
    #raise Forbidden, 'Приглашение другому пользователю' unless @invite.dst_id == current_user.id

    #@invite.status == GroupInviteStatus::Pending
  #end

  def group_invite_params
    params.require(:group_invite).permit([:group_id, :src_id, :dst_id])
  end
end
