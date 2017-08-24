class VotesController < ShikimoriController
  before_action :authenticate_user!

  def create
    Votable::Vote.call(
      votable: params[:type].constantize.find(params[:id]),
      voter: current_user,
      vote: params[:voting] == 'yes'
    )

    render json: {}
  end
end
