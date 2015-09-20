class VotesController < ShikimoriController
  before_filter :authenticate_user!

  def create
    @vote = Vote.find_by(user_id: current_user.id, voteable_id: params[:id], voteable_type: params[:type])
    @vote.destroy if @vote

    @vote = Vote.new(
      user_id: current_user.id,
      voteable_id: params[:id],
      voteable_type: params[:type],
      voting: params[:voting] == 'yes'
    )
    raise Forbidden if @vote.voteable && @vote.voteable.user_id == current_user.id

    if @vote.save
      render json: { } # notice: 'Ваш голос учтён'
    else
      render json: @vote.errors, status: :unprocessable_entity
    end
  end
end
