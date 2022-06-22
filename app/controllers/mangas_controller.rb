class MangasController < AnimesController
  before_action :verify_not_rkn_banned, if: :resource_id

  UPDATE_PARAMS = %i[
    russian
    license_name_ru
    imageboard_tag
    description_ru
    description_en
    is_censored
  ] + [
    *Manga::DESYNCABLE,
    external_links: [EXTERNAL_LINK_PARAMS],
    licensors: [],
    synonyms: [],
    options: [],
    desynced: []
  ]

private

  def og_meta
    book_tags = @resource.genres.map do |genre|
      UsersHelper.localized_name genre, current_user
    end

    og type: 'book'
    og book_release_date: @resource.released_on if @resource.released_on
    og book_tags: book_tags
  end

  def resource_redirect
    if @resource.ranobe?
      return redirect_to current_url(controller: 'ranobe'), status: :moved_permanently
    end

    super
  end

  def update_params
    params
      .require(:manga)
      .permit(UPDATE_PARAMS)
  rescue ActionController::ParameterMissing
    {}
  end

  def verify_not_rkn_banned
    raise RknBanned if @resource.rkn_banned?
  end
end
