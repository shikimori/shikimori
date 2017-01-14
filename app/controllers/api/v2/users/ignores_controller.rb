class Api::V2::Users::IgnoresController < Api::V2Controller
  before_action :authenticate_user!

  resource_description do
    resource_id 'User Ignore'
  end

  api :POST, '/v2/users/:user_id/ignore', 'Ignore a user'
  def create
    Ignore.find_or_create_by(
      target_id: params[:user_id],
      user_id: current_user.id
    )

  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
  ensure
    render json: { user_id: params[:user_id],is_ignored: true }
  end

  api :DELETE, '/v2/users/:user_id/ignore', 'Unignore a user'
  def destroy
    Ignore
      .where(target_id: params[:user_id])
      .where(user_id: current_user.id)
      .destroy_all

    render json: { user_id: params[:user_id], is_ignored: false }
  end
end
