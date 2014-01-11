class GroupRolesController < ApplicationController
  before_filter :authenticate_user!

  # вступление в клуб
  def create
    @group = Group.find(params[:id])
    @user = params.include?(:user_id) ? User.find(params[:user_id]) : current_user
    raise Forbidden unless @group.can_be_joined_by?(@user)
    if @group.has_member? @user
      render json: {}
      return
    end

    # владельца клуба при вступлении делаем админом
    if @group.owner_id == @user.id
      @group.admin_roles.create! user_id: @user.id, role: GroupRole::Admin
    else
      @group.members << @user
    end
    render json: {
      notice: 'Вы вступили в %s' % @group.name,
      member: render_to_string(partial: 'blocks/user', locals: { user: @user, avatar_size: 48 }, formats: :html),
      actions: render_to_string(partial: 'groups/actions', locals: { group: @group }, formats: :html)
    }
  end

  # выход из клуба
  def destroy
    @group = Group.find(params[:id])
    @user = params.include?(:user_id) ? User.find(params[:user_id]) : current_user
    GroupRole.find_by_user_id_and_group_id(@user.id, @group.id).destroy

    render json: {
      notice: 'Вы покинули %s' % @group.name,
      user: @user.id,
      actions: render_to_string(partial: 'groups/actions', locals: { group: @group }, formats: :html)
    }
  end
end
