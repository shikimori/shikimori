class GroupRolesController < ShikimoriController
  load_and_authorize_resource except: [:autocomplete]

  # вступление в клуб
  def create
    @resource.group.join current_user
    redirect_to club_url(@resource.group), notice: "Вы вступили в клуб \"#{@resource.group.name}\""
  end

  # выход из клуба
  def destroy
    @resource.group.leave current_user
    redirect_to club_url(@resource.group), notice: "Вы покинули клуб \"#{@resource.group.name}\""
  end

  def autocomplete
    @collection = GroupRolesQuery
      .new(Group.find(params[:club_id]))
      .complete(params[:search])
  end

private
  def group_role_params
    params.require(:group_role).permit([:group_id, :user_id])
  end
end
