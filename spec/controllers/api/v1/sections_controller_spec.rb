require 'spec_helper'

describe Api::V1::SectionsController do
  describe :index do
    let!(:section) { create :section }

    before { get :index, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
