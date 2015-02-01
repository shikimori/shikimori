class Api::V1::SectionsController < Api::V1::ApiController
  respond_to :json

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/sections', 'List sections'
  def index
    @collection = Section.with_aggregated.to_a
    respond_with @collection
  end
end

