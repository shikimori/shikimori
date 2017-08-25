class VotesController < ShikimoriController
  before_action :authenticate_user!

  VOTE = {
    'yes' => true,
    'no' => false
  }

  # rubocop:disable AbcSize
  def create
    Votable::Vote.call(
      votable: create_params[:votable_type].constantize.find(
        create_params[:votable_id]
      ),
      voter: current_user,
      vote: VOTE.key?(create_params[:vote]) ? VOTE[create_params[:vote]] :
        raise(ArgumentError, create_params[:vote])
    )

    render json: {}
  end
  # rubocop:enable AbcSize

private

  def create_params
    params.require(:vote).permit :votable_type, :votable_id, :vote
  end
end
