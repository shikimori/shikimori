class ContestMatchesController < ShikimoriController
  def show
    og noindex: true
    @resource = ContestMatch.find(params[:id]).decorate
    render formats: :html
  end
end
