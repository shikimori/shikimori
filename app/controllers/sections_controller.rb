class SectionsController < ShikimoriController
  # Отображение раздела
  def show
    params[:section] ||= params[:id].to_i
    @section = Section.find(params[:section])
    redirect_to section_url(section: @section), :status => :moved_permanently # редирект на новый форум
  end
end
