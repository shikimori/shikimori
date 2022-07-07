class UserPreferencesController < ProfilesController
  UPDATE_PARAMS = %i[
    anime_in_profile manga_in_profile favorites_in_profile
    comments_in_profile achievements_in_profile statistics_start_on
    about
    show_hentai_images show_social_buttons
    apply_user_styles is_show_smileys menu_contest
    russian_genres russian_names
    list_privacy comment_policy volumes_in_manga
    is_comments_auto_collapsed is_comments_auto_loaded body_width dashboard_type
    is_shiki_editor
    is_censored_topics
  ] + [
    forums: []
  ]
    # about_on_top

  def update
    authorize! :edit, @resource
    preferences = @resource.preferences

    if preferences.update user_preferences_params
      if preferences.saved_change_to_anime_in_profile? ||
          preferences.saved_change_to_manga_in_profile?
        @resource.touch :rate_at # otherwise cache profile page won't be updated
      end

      return super if params[:user].present?
      return head 200 if request.xhr?

      redirect_to @resource.edit_url(section: params[:section]),
        notice: t('changes_saved')
    else
      flash[:alert] = t 'changes_not_saved'
      edit
      render :edit
    end
  end

private

  def user_preferences_params
    params
      .require(:user_preferences)
      .permit(UPDATE_PARAMS)
      .tap do |fixed_params|
        if fixed_params[:favorites_in_profile] == ''
          fixed_params[:favorites_in_profile] = 0 # can be '' if user deleted input value
        end
      end
  end
end
