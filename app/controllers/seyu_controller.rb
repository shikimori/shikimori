class SeyuController < PeopleController
  before_action :role_redirect, if: :resource_id

  # отображение сэйю
  def show
    @itemtype = @resource.itemtype
  end

  def roles
    page_title 'Роли в аниме'
  end

  def comments
    raise NotFound if @resource.thread.comments_count.zero?
    page_title 'Обсуждение'

    @thread = TopicDecorator.new @resource.thread
    @thread.topic_mode!
  end

private
  def fetch_resource
    @resource = SeyuDecorator.new Person.find(resource_id)
  end

  def role_redirect
    if !@resource.seyu || (@resource.seyu && (@resource.producer || @resource.mangaka))
      if params[:direct]
        @canonical = person_url(@resource)
      else
        redirect_to person_url(@resource)
      end
    end
  end

  def search_title
    'Поиск сэйю'
  end

  def search_url *args
    search_seyu_url(*args)
  end
end
