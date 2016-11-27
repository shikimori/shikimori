class MangasController < AnimesController
  def update_params
    params
      .require(:manga)
      .permit(
        :russian, :tags, :source,
        :description_ru, :description_en,
        *Manga::DESYNCABLE
      )
  end

  def autocomplete
    @collection = Autocomplete::Manga.call(
      scope: Manga.all,
      phrase: params[:search] || params[:q]
    )
  end
end
