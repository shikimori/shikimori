class SeyuController < PeopleController
  page_title 'Сейю'

  def show
    @itemtype = @resource.itemtype
  end

  def roles
    page_title 'Роли в аниме'
  end

private
  def fetch_resource
    super
    @resource = SeyuDecorator.new @resource.object
  end

  def role_redirect
    if !@resource.seyu || (@resource.seyu && (@resource.producer || @resource.mangaka))
      #if params[:direct]
        #@canonical = person_url(@resource)
      #else
        #redirect_to person_url(@resource)
      #end
      redirect_to person_url(@resource)
    end
  end

  def search_title
    'Поиск сэйю'
  end

  def search_url *args
    search_seyu_index_url(*args)
  end

  def resource_klass
    Person
  end
end
