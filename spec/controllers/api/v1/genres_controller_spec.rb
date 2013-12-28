require 'spec_helper'

describe Api::V1::GenresController do
  describe :show do
    let!(:genre) { create :genre }
    before { get :index }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
