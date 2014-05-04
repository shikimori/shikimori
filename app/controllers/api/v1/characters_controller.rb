class Api::V1::CharactersController < Api::V1::ApiController
  respond_to :json
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/characters/:id", "Show a character"
  def show
    respond_with CharacterDecorator.find(params[:id]), serializer: CharacterProfileSerializer
  end
end
