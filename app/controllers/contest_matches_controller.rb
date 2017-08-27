class ContestMatchesController < ShikimoriController
  before_action { noindex }

  # rubocop:disable AbcSize
  # rubocop:disable MethodLength
  def show
    @resource = ContestMatch.find(params[:id]).decorate

    if user_signed_in?
      user_vote = ContestMatch::VOTABLE[
        current_user.voted_as_when_voted_for(@resource)
      ]
    end

    @vote_status =
      if @resource.started?
        user_vote
      elsif @resource.finished?
        if @resource.winner_id == @resource.left_id
          ContestMatch::VOTABLE[true]
        else
          ContestMatch::VOTABLE[false]
        end
      end
  end
  # rubocop:enable MethodLength
  # rubocop:enable AbcSize
end
