describe RecommendationIgnoresController, :type => :controller do
  let(:user) { create :user }
  before { sign_in user }

  describe '#create' do
    let(:anime) { create :anime, kind: 'Special' }

    before { post :create, target_type: Anime.name, target_id: anime.id }

    it { should respond_with 200 }
    it { should respond_with_content_type :json }
    it { expect(json).to eql [anime.id] }
  end

  describe '#cleanup' do
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

    it { should respond_with :success }
    it { expect(RecommendationIgnore.blocked(Anime, user)).to be_empty }
  end
end
