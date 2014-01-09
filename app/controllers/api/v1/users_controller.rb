class Api::V1::UsersController < Api::V1::ApiController
  def show
    @resource = ProfileDecorator.new User.find(params[:id])
  end
end
