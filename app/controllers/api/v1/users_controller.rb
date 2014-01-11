class Api::V1::UsersController < Api::V1::ApiController
  respond_to :json, :xml

  def show
    respond_with UserProfileDecorator.new(User.find(params[:id])), serializer: UserProfileSerializer
  end
end
