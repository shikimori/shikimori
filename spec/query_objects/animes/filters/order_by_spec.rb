describe Animes::Filters::OrderBy do
  describe '#call' do
    subject { described_class.call scope, terms, nil }

    let(:scope) { Anime.all }

    let!(:anime_1) { create :anime, ranked: 10, name: 'AAA', episodes: 10 }
    let!(:anime_2) { create :anime, ranked: 5, name: 'CCC', episodes: 20 }
    let!(:anime_3) { create :anime, ranked: 5, name: 'BBB', episodes: 0, episodes_aired: 15 }

    context 'id' do
      let(:terms) { 'id' }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end

    context 'name' do
      let(:terms) { Animes::Filters::OrderBy::Field[:name] }
      it { is_expected.to eq [anime_1, anime_3, anime_2] }
    end

    context 'ranked' do
      let(:terms) { 'ranked' }
      it { is_expected.to eq [anime_2, anime_3, anime_1] }
    end

    context 'ranked,name' do
      let(:terms) { 'ranked,name' }
      it { is_expected.to eq [anime_3, anime_2, anime_1] }
    end

    context 'custom surtings' do
      context 'user_1' do
        let(:terms) { 'user_1' }
        let(:scope) { Anime.order(:id) }
        it { is_expected.to eq [anime_1, anime_2, anime_3] }
      end

      context 'user_2' do
        let(:terms) { 'user_2' }
        let(:scope) { Anime.order(id: :desc) }
        it { is_expected.to eq [anime_3, anime_2, anime_1] }
      end
    end

    context 'rate_id' do
      let!(:user_rate_2) { create :user_rate, target: anime_2, user: user }
      let!(:user_rate_1) { create :user_rate, target: anime_1, user: user }
      let(:terms) { 'rate_id' }

      context 'no user_rates joined' do
        it { expect { subject }.to raise_error InvalidParameterError }
      end

      context 'has user_rates joined' do
        let(:scope) { Anime.joins :rates }
        it { is_expected.to eq [anime_2, anime_1] }
      end
    end

    context 'invalid parameter' do
      let(:terms) { 'z' }
      it { expect { subject }.to raise_error InvalidParameterError }
    end
  end

  describe '.terms_sql' do
    subject do
      described_class.terms_sql(
        terms: %i[id name],
        scope: [Anime.all, Anime].sample,
        arel_sql: false
      )
    end
    it { is_expected.to eq 'animes.id,animes.name' }
  end

  describe '.term_sql' do
    subject do
      described_class.term_sql(
        term: :id,
        scope: [Anime.all, Anime].sample,
        arel_sql: false
      )
    end
    it { is_expected.to eq 'animes.id' }
  end
end
