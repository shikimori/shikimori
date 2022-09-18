class ClubRolesController < ShikimoriController
  load_and_authorize_resource except: %i[autocomplete]
  load_resource :club

  # join club
  def create
    authorize! :see_club, @club if @club.shadowbanned?
    @club.join current_user

    redirect_to club_url(@club),
      notice: i18n_t(
        '.you_have_joined_club',
        club_name: @club.name,
        gender: current_user.sex
      )
  end

  # leave club
  def destroy
    @club.leave current_user

    redirect_to club_url(@club),
      notice: i18n_t(
        '.you_have_left_club',
        club_name: @club.name,
        gender: current_user.sex
      )
  end

  def autocomplete
    authorize! :see_club, @club

    @collection = ClubRolesQuery
      .new(@club)
      .complete(params[:search])
  end

private

  def club_role_params
    params.require(:club_role).permit(%i[club_id user_id])
  end
end
