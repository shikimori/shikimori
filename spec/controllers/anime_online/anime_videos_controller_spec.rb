require 'spec_helper'

describe AnimeOnline::AnimeVideosController do
  describe :show do
    let(:anime) { create :anime, name: 'anime_test' }
    before { get :show, id: anime.id }

    it { should respond_with_content_type :html }
    it { response.should be_success }
  end

  describe :index do
    before { get :index }
    it { should respond_with_content_type :html }
    it { response.should be_success }
  end
end
