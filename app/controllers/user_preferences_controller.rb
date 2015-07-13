class UserPreferencesController < ProfilesController
  def update
    authorize! :edit, @resource

    if @resource.preferences.update user_preferences_params
      if params[:user].present?
        super
      else
        redirect_to edit_profile_path(@resource, params[:page]), notice: 'Изменения сохранены'
      end

    else
      flash[:alert] = 'Изменения не сохранены!'
      edit
      render :edit
    end
  end

private

  def user_preferences_params
    params.require(:user_preferences).permit(
      :anime_in_profile, :manga_in_profile,
      :comments_in_profile, :statistics_start_on,
      :page_background, :page_border, :body_background, :about_on_top, :about,
      :show_hentai_images, :show_social_buttons, :show_smileys, :menu_contest,
      :russian_genres, :russian_names, :mylist_in_catalog, :postload_in_catalog,
      :list_privacy, :volumes_in_manga,
      :is_comments_auto_collapsed, :is_comments_auto_loaded, :body_width
    )
  end
end
