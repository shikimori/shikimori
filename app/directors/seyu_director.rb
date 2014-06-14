class SeyuDirector < PeopleDirector
  def index
    append_title! "Поиск сэйю"
    append_title! SearchHelper.unescape(params[:search])
  end

  def entry_url_builder
    :seyu_url
  end

  def entry_search_url_builder
    :seyu_search_url
  end
end
