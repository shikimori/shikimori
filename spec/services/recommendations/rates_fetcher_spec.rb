describe Recommendations::RatesFetcher do
  let(:service) { described_class.new klass, user_ids }
  let(:klass) { Anime }
  let(:user_ids) { nil }

  before do
    stub_const 'Recommendations::RatesFetcher::MINIMUM_SCORES', minimum_scores
  end
  let(:minimum_scores) { 1 }

  describe '#fetch' do
    let(:anime_1) { create :anime }
    let(:anime_2) { create :anime }
    let(:user_2) { create :user }

    let!(:user_rate_1) { create :user_rate, :completed, target: anime_1, user: user, score: 4 }
    let!(:user_rate_2) { create :user_rate, :completed, target: anime_2, user: user, score: 5 }
    let!(:user_rate_3) { create :user_rate, :completed, target: anime_2, user: user_2, score: 6 }

    let(:normalization) { Recommendations::Normalizations::None.new }

    subject { service.fetch normalization }

    it do
      is_expected.to eq(
        user.id => {
          anime_1.id => user_rate_1.score,
          anime_2.id => user_rate_2.score
        },
        user_2.id => {
          anime_2.id => user_rate_3.score
        }
      )
    end

    context 'with normalization' do
      let(:user_ids) { [user.id] }
      let(:normalization) { Recommendations::Normalizations::ZScore.new }

      it do
        is_expected.to eq(
          user.id => {
            anime_1.id => -0.7071067811865475,
            anime_2.id => 0.7071067811865475
          }
        )
      end
    end

    context 'limit by minimum scores' do
      let(:minimum_scores) { 2 }

      context 'with deletion' do
        it do
          is_expected.to eq(
            user.id => {
              anime_1.id => user_rate_1.score,
              anime_2.id => user_rate_2.score
            }
          )
        end
      end

      context 'w/o deletion' do
        before { service.with_deletion = false }
        it do
          is_expected.to eq(
            user.id => {
              anime_1.id => user_rate_1.score,
              anime_2.id => user_rate_2.score
            },
            user_2.id => {
              anime_2.id => user_rate_3.score
            }
          )
        end
      end
    end

    context 'filter by user_rate.score' do
      let!(:user_rate_1) { create :user_rate, :completed, target: anime_1, user: user, score: 4 }
      let!(:user_rate_2) { create :user_rate, :completed, target: anime_2, user: user, score: 0 }
      let!(:user_rate_3) { create :user_rate, :completed, target: anime_1, user: user_2, score: 0 }

      it do
        is_expected.to eq(
          user.id => {
            anime_1.id => user_rate_1.score
          }
        )
      end
    end

    context 'filter by db_entry.kind' do
      let(:anime_2) { create :anime, %i[music special].sample }

      it do
        is_expected.to eq(
          user.id => {
            anime_1.id => user_rate_1.score
          }
        )
      end
    end

    context 'filter by user_ids' do
      let(:user_ids) { [user.id] }

      it do
        is_expected.to eq(
          user.id => {
            anime_1.id => user_rate_1.score,
            anime_2.id => user_rate_2.score
          }
        )
      end
    end

    context 'filter by target_ids' do
      before { service.target_ids = [anime_1.id] }

      it do
        is_expected.to eq(
          user.id => {
            anime_1.id => user_rate_1.score
          }
        )
      end
    end
  end
end
