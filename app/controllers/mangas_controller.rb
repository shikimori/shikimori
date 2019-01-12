class MangasController < AnimesController
  UPDATE_PARAMS = %i[
    russian
    license_name_ru
    imageboard_tag
    description_ru
    description_en
  ] + [
    *Manga::DESYNCABLE,
    external_links: [EXTERNAL_LINK_PARAMS],
    synonyms: []
  ]

  def autocomplete
    scope = Manga.where.not(kind: Ranobe::KIND)
    scope.where! censored: false if params[:censored] == 'false'

    @collection = Autocomplete::Manga.call(
      scope: scope,
      phrase: params[:search] || params[:q]
    )
  end

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
      return redirect_to current_url(controller: 'ranobe'), status: 301
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
end
