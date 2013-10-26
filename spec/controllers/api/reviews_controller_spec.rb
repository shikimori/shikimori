require 'spec_helper'

describe Api::ReviewsController do
  before do
    get :show, id: create(:review).id, format: :json
  end

  it { should respond_with_content_type(:json) }
  it { should assign_to(:resource) }
end
