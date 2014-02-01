class PeopleQuery
  include CompleteQuery
  WorksLimit = 5

  def initialize(params, klass=Person)
    @search = SearchHelper.unescape params[:search]
    @page = (params[:page] || 1).to_i
    @kind = (params[:kind] || '').to_sym
    @klass = klass
  end

  def fetch
    people_ids = []
    query = @klass.where(search_queries.join(' or '))
    query = query.where(@kind => true) if @kind.present?
    search_order query
  end

  def fill_works(fetched_query)
    people_by_id = fill_by_id fetched_query

    work_klass = producer? ? Anime : Manga
    work_key = producer? ? :anime_id : :manga_id

    roles = PersonRole
      .where(person_id: fetched_query.map(&:id))
      .where { person_roles.send(work_key).not_eq(0) }
      .select([:person_id, work_key])
      .to_a

    role_people = roles.each_with_object({}) do |role,memo|
      (memo[role[work_key]] = memo[role[work_key]] || []) << people_by_id[role.person_id]
    end

    works = work_klass
      .where(id: role_people.keys)
      .order(score: :desc)
      .to_a

    works.sort_by {|v| v.aired_on || v.released_on || DateTime.now - 99.years }.reverse.each do |entry|
      role_people[entry.id].each do |person|
        break if person.last_works.size >= WorksLimit
        person.last_works << entry
      end
    end

    works.each do |entry|
      role_people[entry.id].each do |person|
        break if person.best_works.size >= WorksLimit
        person.best_works << entry
      end
    end

    fetched_query
  end

  # режиссёра ли мы выбираем?
  def producer?
    @kind == :producer
  end

private
  # ключи, по которым будет вестись поиск
  def search_fields(term)
    if term.contains_cjkv?
      [:japanese]
    else
      [:name]
    end
  end

  def fill_by_id(fetched_query)
    fetched_query.each_with_object({}) do |entry, memo|
      class << entry; attr_accessor :last_works, :best_works; end

      entry.last_works = []
      entry.best_works = []

      memo[entry.id] = entry
    end
  end
end
