class RanobeController < AnimesController
  UPDATE_PARAMS = MangasController::UPDATE_PARAMS

private

  def og_meta
    book_tags = @resource.genres.map do |genre|
      UsersHelper.localized_name genre, current_user
    end

    og type: 'book'
    og book_release_date: @resource.released_on.date if @resource.released_on.present?
    og book_tags: book_tags
  end

  def resource_redirect
    if @resource.manga?
      return redirect_to current_url(controller: 'mangas'), status: :moved_permanently
    end

    super
  end

  def update_params
    params
      .require(:ranobe)
      .permit(UPDATE_PARAMS)
  rescue ActionController::ParameterMissing
    {}
  end
end
