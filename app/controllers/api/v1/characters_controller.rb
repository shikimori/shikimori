class Api::V1::CharactersController < Api::V1::ApiController
  def show
    @resource = Character.find params[:id]
  end
end
