class Autocomplete::FansubbersController < ShikimoriController
  include SearchPhraseConcern

  def index
    render json: Search::Fansubber.call(
      phrase: search_phrase,
      ids_limit: Autocomplete::AutocompleteBase::LIMIT,
      kind: params[:kind]
    )
  end
end
