class ContestSuggestionsController < ShikimoriController
  before_action :authenticate_user!
  before_action :fetch_contest

  def show
    @suggestion = ContestSuggestion.find params[:id]
    @voters = Rails.cache.fetch [@suggestion, @suggestion.contest, 'voters'] do
      @suggestion
        .contest
        .suggestions
        .where(item_type: @suggestion.item_type, item_id: @suggestion.item_id)
        .includes(:user)
        .map(&:user)
    end

    render :show, layout: nil
  end

  def create
    item = params[:contest_suggestion][:item_type].constantize.find(
      params[:contest_suggestion][:item_id]
    )
    ContestSuggestion.suggest @contest, current_user, item

    redirect_to contest_url(@contest)
  end

  def destroy
    @contest
      .suggestions
      .where(id: params[:id])
      .where(user_id: current_user.id)
      .first!
      .destroy

    redirect_to contest_url(@contest)
  end

private

  def fetch_contest
    @contest = Contest.where(id: params[:contest_id], state: 'proposing').first!
  end
end
