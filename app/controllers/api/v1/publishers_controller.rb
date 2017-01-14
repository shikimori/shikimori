class Api::V1::PublishersController < Api::V1Controller
  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/publishers', 'List publishers'
  def index
    @collection = Publisher.all.to_a
    respond_with @collection
  end
end
