# TODO: страница косплея, страница картинок с имиджборд
class CharactersController < PeopleController
  before_action :authenticate_user!, only: [:edit]
  skip_before_action :role_redirect

  page_title 'Персонажи'

  #caches_action :index, CacheHelper.cache_settings
  #caches_action :page, :show, :tooltip,
    #cache_path: proc {
      #entry = Character.find(params[:id].to_i)
      #"#{Character.name}|#{params.to_json}|#{entry.updated_at.to_i}|#{entry.thread.updated_at.to_i}|#{json?}"
    #},
    #unless: proc { user_signed_in? },
    #expires_in: 2.days

  def show
    @itemtype = @resource.itemtype
  end

  # все сэйю персонажа
  def seyu
    redirect_to @resource.url if @resource.seyu.none?
    page_title 'Сэйю'
  end

  # все аниме персонажа
  def animes
    redirect_to @resource.url if @resource.animes.none?
    page_title 'Анимеграфия'
  end

  # вся манга персонажа
  def mangas
    redirect_to @resource.url if @resource.mangas.none?
    page_title 'Мангаграфия'
  end

  def comments
    redirect_to @resource.url if @resource.main_thread.comments_count.zero?
    page_title 'Обсуждение персонажа'
  end

  def art
    page_title 'Арт с имиджборд'
  end

  def favoured
    redirect_to @resource.url if @resource.all_favoured.none?
    page_title 'В избранном'
  end

  def clubs
    redirect_to @resource.url if @resource.all_linked_clubs.none?
    page_title 'Клубы'
  end

  def tooltip
  end

  def edit
    noindex
    page_title 'Редактирование'
    @page = params[:page] || 'description'

    @user_change = UserChange.new(
      model: @resource.object.class.name,
      item_id: @resource.id,
      column: @page,
      source: @resource.source,
      value: @resource[@page]
    )
  end

  def autocomplete
    @collection = CharactersQuery.new(params).complete
  end

private
  def search_title
    'Поиск персонажей'
  end

  def search_url *args
    search_characters_url(*args)
  end

  def search_query
    CharactersQuery.new params
  end
end
