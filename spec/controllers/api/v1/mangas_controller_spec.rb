require 'spec_helper'

describe Api::V1::MangasController do
  describe :show do
    let(:manga) { create :manga }
    before { get :show, id: manga.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
