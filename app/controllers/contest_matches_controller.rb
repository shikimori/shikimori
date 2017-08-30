class ContestMatchesController < ShikimoriController
  before_action { noindex }

  def show
    @resource = ContestMatch.find(params[:id]).decorate
  end
end
