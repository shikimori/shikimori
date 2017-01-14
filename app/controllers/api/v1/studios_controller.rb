class Api::V1::StudiosController < Api::V1Controller
  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/studios', 'List studios'
  def index
    @collection = Studio.all
    respond_with @collection.to_a
  end
end
