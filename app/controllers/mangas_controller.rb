class MangasController < AnimesController
  def autocomplete
    @collection = Autocomplete::Manga.call(
      scope: Manga.all,
      phrase: params[:search] || params[:q]
    )
  end

private

  def update_params
    params
      .require(:manga)
      .permit(
        :russian,
        :tags,
        :description_ru,
        :description_en,
        *Manga::DESYNCABLE
      )
  end
end
