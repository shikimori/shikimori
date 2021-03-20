describe RecommendationIgnore do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :target }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:target_id, :target_type) }
  end

  context 'class_methods' do
    let(:anime1) { create :anime, kind: :special }
    let(:anime_2) { create :anime }
    let(:anime_3) { create :anime }

    before { Animes::BannedRelations.instance.clear_cache! }
    after(:all) { Animes::BannedRelations.instance.clear_cache! }

    describe '.block' do
      let!(:related_1) { create :related_anime, source_id: anime_2.id, anime_id: anime_3.id }
      let!(:related_2) { create :related_anime, source_id: anime_3.id, anime_id: anime_2.id }

      subject { RecommendationIgnore.block anime_3, user }

      it do
        expect { subject }.to change(RecommendationIgnore, :count).by 2
        is_expected.to eq [anime_3.id, anime_2.id]
      end

      describe 'second run' do
        before { RecommendationIgnore.block anime_3, user }

        it do
          expect { subject }.to_not change(RecommendationIgnore, :count)
          is_expected.to eq [anime_3.id]
        end
      end

      describe 'block of new entry' do
        let(:anime_4) { create :anime }
        before { RecommendationIgnore.block anime_3, user }

        let!(:related_3) { create :related_anime, source_id: anime_2.id, anime_id: anime_4.id }
        let!(:related_4) { create :related_anime, source_id: anime_4.id, anime_id: anime_2.id }

        it do
          expect { subject }.to change(RecommendationIgnore, :count).by 1
          is_expected.to eq [anime_4.id, anime_3.id]
        end
      end
    end
  end
end
