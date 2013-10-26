class PeopleDirector < BaseDirector
  def index
    append_title! "Поиск #{producer? ? 'режиссёра' : (mangaka? ? 'мангаки' : 'человека')}"
    append_title! SearchHelper.unescape(params[:search])
  end

  def show
    noindex && nofollow
    append_title! entry.job_title
    append_title! entry.name
    redirect!
  end

  def tooltip
    noindex && nofollow
    redirect! person_tooltip_url(entry)
  end

  def entry_url_builder
    :person_url
  end

  def entry_search_url_builder
    if producer?
      :producer_search_url
    elsif mangaka?
      :mangaka_search_url
    else
      :people_search_url
    end
  end

private
  def producer?
    params[:kind] == 'producer'
  end

  def mangaka?
    params[:kind] == 'mangaka'
  end

  def redirect?
    entry.to_param != params[:id]
  end
end
