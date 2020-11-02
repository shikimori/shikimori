class Autocomplete::LicensorsController < ShikimoriController
  def index
    render json: Search::Licensor.call(
      phrase: params[:search] || params[:q],
      ids_limit: Autocomplete::AutocompleteBase::LIMIT,
      kind: params[:kind]
    )
  end
end
