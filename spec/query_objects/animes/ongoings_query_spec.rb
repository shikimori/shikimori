describe Animes::OngoingsQuery do
  let(:query) { Animes::OngoingsQuery.new is_adult }
  let(:is_adult) { false }
  let(:limit) { 2 }

  subject(:result) { query.fetch limit }

  describe '#fetch' do
    context 'ongoing fileter' do
      let!(:anons) { create :anime, :anons }
      let!(:released) { create :anime, :released }
      let!(:ongoing) { create :anime, :ongoing }

      it { expect(result).to eq [ongoing] }
    end

    context 'score filter' do
      let!(:ongoing_1) { create :anime, :ongoing, score: 10 }
      let!(:ongoing_2) { create :anime, :ongoing }

      it { expect(result).to eq [ongoing_2] }
    end

    context 'rating filter' do
      let!(:ongoing_1) { create :anime, :ongoing, rating: :g }
      let!(:ongoing_2) { create :anime, :ongoing }

      it { expect(result).to eq [ongoing_2] }
    end

    context 'adult filter' do
      context 'is_adult' do
        let!(:ongoing_1) { create :anime, :ongoing, is_censored: true }
        let!(:ongoing_2) { create :anime, :ongoing, is_censored: false }

        context 'adult' do
          let(:is_adult) { true }
          it { expect(result).to eq [ongoing_1] }
        end

        context 'not adult' do
          let(:is_adult) { false }
          it { expect(result).to eq [ongoing_2] }
        end
      end
    end

    context 'Anime::EXCLUDED_ONGOINGS filter' do
      let!(:ongoing_1) { create :anime, :ongoing, id: Anime::EXCLUDED_ONGOINGS.first }
      let!(:ongoing_2) { create :anime, :ongoing }

      it { expect(result).to eq [ongoing_2] }
    end

    context 'limit' do
      let!(:ongoing_1) { create :anime, :ongoing, ranked: 10 }
      let!(:ongoing_2) { create :anime, :ongoing, ranked: 1 }

      context '1' do
        let(:limit) { 1 }
        it { expect(result).to eq [ongoing_2] }
      end

      context '2' do
        let(:limit) { 2 }
        it { expect(result).to eq [ongoing_2, ongoing_1] }
      end
    end
  end
end
