class ClubRolesController < ShikimoriController
  load_and_authorize_resource except: [:autocomplete]

  # join club
  def create
    @resource.club.join current_user

    redirect_to club_url(@resource.club),
      notice: i18n_t(
        '.you_have_joined_club',
        club_name: @resource.club.name,
        gender: current_user.sex
      )
  end

  # leave club
  def destroy
    @resource.club.leave current_user
    redirect_to club_url(@resource.club),
      notice: i18n_t(
        '.you_have_left_club',
        club_name: @resource.club.name,
        gender: current_user.sex
      )
  end

  def autocomplete
    @collection = ClubRolesQuery
      .new(Club.find(params[:club_id]))
      .complete(params[:search])
  end

private

  def club_role_params
    params.require(:club_role).permit(%i[club_id user_id])
  end
end
