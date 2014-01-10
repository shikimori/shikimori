class Api::V1::UsersController < Api::V1::ApiController
  def show
    @resource = UserProfileDecorator.new User.find(params[:id])
  end
end
