class Users::ListExportsController < ProfilesController
  before_action do
    authorize! :access_list, @user

    @back_url = edit_profile_url @user, page: :list
    breadcrumb t(:settings), edit_profile_url(@user, page: :list)
    page_title t(:settings)
  end

  def show
    page_title i18n_t(:title)
  end

  def animes
    @collection = @user.anime_rates.includes(:anime)
    @export_type = UserRatesImporter::ANIME_TYPE

    export
  end

  def mangas
    @collection = @user.manga_rates.includes(:manga)
    @export_type = UserRatesImporter::MANGA_TYPE

    export
  end

private

  def export
    response.headers['Content-Description'] = 'File Transfer'
    response.headers['Content-Disposition'] =
      "attachment; filename=animelist.#{params[:format]}"

    render :export
  end
end
