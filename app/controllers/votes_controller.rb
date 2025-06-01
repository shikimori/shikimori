class VotesController < ShikimoriController
  before_action :authenticate_user!

  VOTABLE_TYPES = %w[
    Critique
    Review
    Collection
    Poll
    PollVariant
    ContestMatch
    CosplayGallery
  ]

  def create
    if(VOTABLE_TYPES.include?(params[:votable_type]))
      Votable::Vote.call(
        votable: params[:votable_type].constantize.find(
          params[:votable_id]
        ),
        voter: current_user,
        vote: params[:vote]
      )

      render json: {}
    else
      render json: { error: 'Incompatible votable_type supplied' }, status: 422
    end
  end
end
