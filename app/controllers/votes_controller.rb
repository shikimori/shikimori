class VotesController < ShikimoriController
  before_action :authenticate_user!

  def create
    Votable::Vote.call(
      votable: params[:votable_type].constantize.find(
        params[:votable_id]
      ),
      voter: current_user,
      vote: params[:vote]
    )

    render json: {}
  end
end
