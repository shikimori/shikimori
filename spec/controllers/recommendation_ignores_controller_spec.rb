describe RecommendationIgnoresController do
  include_context :authenticated, :user

  after { Animes::BannedRelations.instance.clear_cache! }

  describe '#create' do
    let(:anime) { create :anime, :special }

    before do
      post :create,
        params: {
          target_type: Anime.name,
          target_id: anime.id
        }
    end

    it do
      expect(user.recommendation_ignores).to have(1).item
      expect(user.recommendation_ignores.first).to have_attributes(
        target: anime
      )

      expect(json).to eq [anime.id]

      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#cleanup' do
    let(:anime1) { create :anime, :special }
    let(:anime2) { create :anime }
    let(:anime3) { create :anime }

    let!(:recommendation_ignore_1) do
      create :recommendation_ignore, user: user, target: create(:manga)
    end
    let!(:recommendation_ignore_2) do
      create :recommendation_ignore, user: user, target: anime1
    end
    let!(:recommendation_ignore_3) do
      create :recommendation_ignore, user: user, target: anime2
    end
    let!(:recommendation_ignore_4) do
      create :recommendation_ignore, user: create(:user), target: anime3
    end

    before { delete :cleanup, params: { target_type: 'anime' } }

    it do
      expect(user.recommendation_ignores.where(target_type: 'Anime')).to be_empty
      expect(response).to have_http_status :success
    end
  end
end
