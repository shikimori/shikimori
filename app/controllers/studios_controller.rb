class StudiosController < ShikimoriController
  # список студий
  def index
    @page_title = i18n_t 'page_title'
    @description = i18n_t 'description'
    set_meta_tags description: @description

    @collection = Studio
      .joins(:animes)
      .where("animes.kind != 'Special'")
      .group('studios.id')
      .select('studios.*, count(animes.id) as animes_count, max(animes.aired_on) as max_year, min(animes.aired_on) as min_year')
      .order('animes_count desc')
  end
end
