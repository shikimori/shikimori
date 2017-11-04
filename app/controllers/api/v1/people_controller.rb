class Api::V1::PeopleController < Api::V1Controller
  before_action :fetch_resource, except: [:search]

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/people/:id', 'Show a person'
  def show
    person = @resource.decorate

    if person.main_role? :seyu
      respond_with SeyuDecorator.new(@resource), serializer: SeyuProfileSerializer
    else
      respond_with person, serializer: PersonProfileSerializer
    end
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/people/search'
  def search
    @collection = Autocomplete::Person.call(
      scope: Person.all,
      phrase: SearchHelper.unescape(params[:search] || params[:q]),
      is_seyu: params[:kind] == 'seyu',
      is_mangaka: params[:kind] == 'mangaka',
      is_producer: params[:kind] == 'producer'
    )
    respond_with @collection, each_serializer: PersonSerializer
  end

private

  def fetch_resource
    @resource = Person.find(
      CopyrightedIds.instance.restore_id(params[:id])
    )
  end
end
