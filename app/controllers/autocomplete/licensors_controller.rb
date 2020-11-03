class Autocomplete::LicensorsController < ShikimoriController
  include SearchPhraseConcern

  def index
    render json: Search::Licensor.call(
      phrase: search_phrase,
      ids_limit: Autocomplete::AutocompleteBase::LIMIT,
      kind: params[:kind]
    )
  end
end
