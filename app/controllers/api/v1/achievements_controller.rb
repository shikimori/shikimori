class Api::V1::AchievementsController < Api::V1Controller
  api :GET, '/achievements', 'List user achievements'
  param :user_id, :number, required: true
  def index
    @collection = Achievement.where(user_id: params[:user_id])
    respond_with @collection
  end
end
