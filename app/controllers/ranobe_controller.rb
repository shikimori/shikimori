class RanobeController < AnimesController
  def autocomplete
    @collection = Autocomplete::Ranobe.call(
      scope: Ranobe.all,
      phrase: params[:search] || params[:q]
    )
  end

private

  def resource_redirect
    if @resource.manga?
      redirect_url =
        url_for(url_params.merge(action: params[:action], controller: 'mangas'))
      return redirect_to redirect_url, status: 301
    end

    super
  end

  def update_params
    params
      .require(:ranobe)
      .permit(
        :russian,
        :tags,
        :description_ru,
        :description_en,
        *Manga::DESYNCABLE
      )
  end
end
