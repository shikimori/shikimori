describe Animes::Filters::ByUserList do
  subject { described_class.call Anime.order(:id), terms, user }

  let!(:anime_1) { create :anime, score: 9 }
  let!(:anime_2) { create :anime, score: 8 }
  let!(:anime_3) { create :anime, score: 7 }

  let!(:anime_4) { create :anime }
  let!(:anime_5) { create :anime }

  let!(:user_rate_1) { create :user_rate, :planned, target: anime_1, user: user }
  let!(:user_rate_2) { create :user_rate, :watching, target: anime_2, user: user }
  let!(:user_rate_3) { create :user_rate, :watching, target: anime_3, user: user }

  context 'positive' do
    context 'planned' do
      let(:terms) { 'planned' }
      it { is_expected.to eq [anime_1] }
    end

    context 'status as numeric index' do
      let(:terms) { UserRate.statuses[:planned].to_s }
      it { is_expected.to eq [anime_1] }
    end

    context 'watching' do
      let(:terms) { 'watching' }
      it { is_expected.to eq [anime_2, anime_3] }
    end

    context 'planned,watching' do
      let(:terms) { 'planned,watching' }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end
  end

  context 'negative' do
    context '!planned' do
      let(:terms) { '!planned' }
      it { is_expected.to eq [anime_2, anime_3, anime_4, anime_5] }
    end

    context '!planned,!watching' do
      let(:terms) { '!planned,!watching' }
      it { is_expected.to eq [anime_4, anime_5] }
    end
  end

  context 'both' do
    context 'planned,!watching' do
      let(:terms) { "#{UserRate.statuses[:planned]},!#{UserRate.statuses[:watching]}" }
      it { is_expected.to eq [anime_1] }
    end
  end
end
