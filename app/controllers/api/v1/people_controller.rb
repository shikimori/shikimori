class Api::V1::PeopleController < Api::V1::ApiController
  respond_to :json
  before_action :fetch_resource, except: [:search]

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/people/:id', 'Show a person'
  def show
    if @resource.seyu?
      respond_with SeyuDecorator.new(@resource), serializer: SeyuProfileSerializer
    else
      respond_with PersonDecorator.new(@resource), serializer: PersonProfileSerializer
    end
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/people/search'
  def search
    @collection = PeopleQuery.new(search: params[:q]).complete
    respond_with @collection, each_serializer: PersonSerializer
  end

  def fetch_resource
    @resource = Person.find(
      CopyrightedIds.instance.restore(params[:id], :person)
    )
  end
end
