require 'spec_helper'

describe AnimeOnline::AnimeVideosController do
  let(:anime) { create :anime, name: 'anime_test' }

  describe :show do
    before { get :show, id: anime.id }

    it { should respond_with_content_type :html }
    it { response.should be_success }
  end

end
