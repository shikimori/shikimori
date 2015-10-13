class SeyuController < PeopleController
  before_action { page_title t('seyu') }

  def show
    @itemtype = @resource.itemtype
  end

  def roles
    noindex
    page_title t('roles_in_anime')
  end

private
  def fetch_resource
    super
    @resource = SeyuDecorator.new @resource.object
  end

  def role_redirect
    redirect_to person_url(@resource), status: 301 unless @resource.main_role?(:seyu)
  end

  def search_title
    i18n_t 'search_seyu'
  end

  def search_url *args
    search_seyu_index_url(*args)
  end

  def resource_klass
    Person
  end
end
