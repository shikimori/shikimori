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
    item_type = create_params[:item_type]

    if(Types::Contest::MemberType.include?(item_type.downcase.to_sym))
      item = item_type.constantize.find(
        create_params[:item_id]
      )
      ContestSuggestion.suggest @contest, current_user, item

      redirect_to contest_url(@contest)
    else
      render json: { error: 'Incompatible item_type supplied' }, status: 422
    end
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

  def create_params
    params.require(:contest_suggestion).permit(:item_type, :item_id)
  end
end
