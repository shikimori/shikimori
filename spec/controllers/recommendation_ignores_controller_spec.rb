require 'spec_helper'

describe RecommendationIgnoresController do
  let(:user) { create :user }
  before { sign_in user }

  describe :create do
    let(:anime) { create :anime, kind: 'Special' }
    let(:json) { JSON.parse response.body }

    before { post :create, target_type: Anime.name, target_id: anime.id }

    it { should respond_with 200 }
    it { should respond_with_content_type :json }
    it { json.should eql [anime.id] }
  end

  describe :cleanup do
    let(:anime1) { create :anime, kind: 'Special' }
    let(:anime2) { create :anime }
    let(:anime3) { create :anime }
    before do
      create :recommendation_ignore, user: user, target: create(:manga)
      create :recommendation_ignore, user: user, target: anime1
      create :recommendation_ignore, user: user, target: anime2
      create :recommendation_ignore, user: create(:user), target: anime3

      delete :cleanup, target_type: 'anime'
    end

    it { should respond_with 302 }
    it { RecommendationIgnore.blocked(Anime, user).should be_empty }
    it { RecommendationIgnore.blocked(Anime, user) }
  end
end
