# TODO: refactor into view object
# :best_works, :best_roles - refactor to query objects
class StudioDecorator < DbEntryDecorator
  def url
    h.animes_collection_url(studio: object)
  end

  def headline_array
    [object.name]
  end
end
