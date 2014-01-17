require 'spec_helper'

describe Api::V1::AnimesController do
  describe :show do
    let(:anime) { create :anime, :with_thread }
    before { get :show, id: anime.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
