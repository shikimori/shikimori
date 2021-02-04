describe Animes::RefreshStats do
  subject { described_class.call scope }
  let(:scope) { Anime.all }

  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime }

  before { user_3.update roles: %i[cheat_bot] }
  let!(:anime_1_rate_1) do
    create :user_rate,
      target: anime_1,
      user: user_1,
      status: :completed,
      score: 10
  end
  let!(:anime_1_rate_2) do
    create :user_rate,
      target: anime_1,
      user: user_2,
      status: :completed,
      score: 8
  end
  let!(:anime_1_rate_3) do
    create :user_rate,
      target: anime_1,
      user: user_3,
      status: :dropped,
      score: 1
  end
  let!(:anime_2_rate_1) do
    create :user_rate,
      target: anime_2,
      user: user_1,
      status: :completed,
      score: 10
  end

  context 'no anime stat' do
    it do
      expect { subject }.to change(AnimeStat, :count).by 2
    end
  end

  context 'has anime stat' do
    let!(:anime_stat_2) { create :anime_stat, entry: anime_2 }
    it do
      expect { subject }.to change(AnimeStat, :count).by 1
      expect { anime_stat_2.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
