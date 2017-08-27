class VotesController < ShikimoriController
  before_action :authenticate_user!

  VOTE = {
    'yes' => true,
    'no' => false,
    'abstain' => 'abstain'
  }

  # rubocop:disable AbcSize
  def create
    Votable::Vote.call(
      votable: params[:votable_type].constantize.find(
        params[:votable_id]
      ),
      voter: current_user,
      vote: VOTE.key?(params[:vote]) ? VOTE[params[:vote]] :
        raise(ArgumentError, params[:vote])
    )

    render json: {}
  end
  # rubocop:enable AbcSize
end
