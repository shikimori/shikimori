class StudiosController < ApplicationController
  # список студий
  def index
    @page_title = 'Аниме студии'
    @description = 'Список наиболее крупных студий, занимающихся созданием аниме; отсортировано по объёму работ.'
    set_meta_tags description: @description

    @studios = Studio
      .joins(:animes)
      .where("animes.kind != 'Special'")
      .group('studios.id')
      .select('studios.*, count(animes.id) as animes_count, max(animes.aired_on) as max_year, min(animes.aired_on) as min_year')
      .order('animes_count desc')

  end
end
