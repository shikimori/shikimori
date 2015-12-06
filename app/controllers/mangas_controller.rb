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
end
