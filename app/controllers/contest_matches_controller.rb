class ContestMatchesController < ApplicationController
  before_filter :authenticate_user!, only: [:vote]
  layout nil

  def show
    @match = ContestMatch
      .with_user_vote(current_user, remote_addr)
      .where(id: params[:id])
      .first!
      .decorate
  end

  def vote
    @match = ContestMatch.find(params[:id]).decorate
    @match.vote_for params[:variant], current_user, remote_addr
    @match.update_user current_user, remote_addr

    render json: {
      vote_id: @match.id,
      variant: params[:variant]
    }
  rescue ActiveRecord::RecordNotUnique => e
    render json: ['С вашего IP адреса здесь уже проголосовали'], status: :unprocessable_entity
  end
end
