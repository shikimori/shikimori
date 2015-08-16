class MangasController < AnimesController
  def update_params
    params
      .require(:manga)
      .permit(:russian, :tags, :description, :source, *Manga::DESYNCABLE)
  end
end
