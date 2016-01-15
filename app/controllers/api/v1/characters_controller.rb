class Api::V1::CharactersController < Api::V1::ApiController
  respond_to :json
  before_action :fetch_resource, except: [:search]

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/characters/:id', 'Show a character'
  def show
    respond_with @resource,
      serializer: CharacterProfileSerializer,
      scope: view_context
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/characters/search'
  def search
    @collection = CharactersQuery.new(search: params[:q]).complete
    respond_with @collection, each_serializer: CharacterSerializer
  end

private

  def fetch_resource
    @resource = Character.find(
      CopyrightedIds.instance.restore(params[:id], :character)
    ).decorate
  end
end
