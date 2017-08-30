class VotesController < ShikimoriController
  before_action :authenticate_user!

  # rubocop:disable AbcSize
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
  # rubocop:enable AbcSize
end
