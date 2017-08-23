class VotesController < ShikimoriController
  before_action :authenticate_user!

  def create
    votable = params[:type].constantize.find(params[:id])

    if params[:voting] == 'yes'
      current_user.likes votable
    else
      current_user.dislikes votable
    end

    render json: {}
  end
end
