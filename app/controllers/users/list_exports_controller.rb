class Users::ListExportsController < ProfilesController
  before_action do
    authorize! :access_list, @user

    @back_url = edit_profile_url @user, section: :list
    breadcrumb t(:settings), edit_profile_url(@user, section: :list)
    og page_title: t(:settings)
  end

  def show
    og page_title: i18n_t(:title)
  end

  def animes
    @collection = @user.anime_rates.includes(:anime).order(:id)
    @export_type = ::ListImports::ParseXml::ANIME_TYPE

    export
  end

  def mangas
    @collection = @user.manga_rates.includes(:manga).order(:id)
    @export_type = ::ListImports::ParseXml::MANGA_TYPE

    export
  end

private

  def export
    response.headers['Content-Description'] = 'File Transfer'
    response.headers['Content-Disposition'] = 'attachment; filename='\
      "#{@user.to_param}_#{params[:action]}.#{params[:format]}"

    render :export
  end
end
