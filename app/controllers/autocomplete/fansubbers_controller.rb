class Autocomplete::FansubbersController < ShikimoriController
  def index
    render json: Search::Fansubber.call(
      phrase: params[:search] || params[:q],
      ids_limit: Autocomplete::AutocompleteBase::LIMIT,
      kind: params[:kind]
    )
  end
end
