class Api::V1::CharactersController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/characters/:id", "Show a character"
  def show
    @resource = CharacterDecorator.find params[:id]
  end
end
