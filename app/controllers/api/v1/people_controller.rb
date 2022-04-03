class Api::V1::PeopleController < Api::V1Controller
  include SearchPhraseConcern
  before_action :fetch_resource, except: %i[search]

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/people/:id', 'Show a person'
  def show
    respond_with PersonDecorator.new(@resource),
      serializer: PersonProfileSerializer
  end

  api :GET, '/people/search', 'Search people'
  param :search, String, required: false, allow_blank: true
  param :kind, %w[seyu mangaka producer], required: false
  def search
    @collection = Autocomplete::Person.call(
      scope: Person.all,
      phrase: search_phrase,
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
