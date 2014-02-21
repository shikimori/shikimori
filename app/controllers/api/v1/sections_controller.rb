class Api::V1::SectionsController < Api::V1::ApiController
  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/sections", "List sections"
  def index
    respond_with Section.all
  end
end

