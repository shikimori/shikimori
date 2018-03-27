describe Animes::UpdateCachedRatesCounts do
  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime }
  let!(:anime_3) { create :anime }

  let!(:manga_1) { create :manga }
  let!(:manga_2) { create :manga }

  let(:user_1) { seed :user }
  let(:user_2) { create :user }

  let!(:anime_rate_1_1) { create :user_rate, target: anime_1, user: user_1 }
  let!(:anime_rate_1_2) { create :user_rate, target: anime_1, user: user_2 }
  let!(:anime_rate_2_1) { create :user_rate, target: anime_2, user: user_1 }

  let!(:manga_rate_1_1) { create :user_rate, target: manga_1, user: user_1 }
  let!(:manga_rate_1_2) { create :user_rate, target: manga_1, user: user_2 }

  subject! { Animes::UpdateCachedRatesCounts.new.perform }

  it do
    expect(anime_1.reload.cached_rates_count).to eq 2
    expect(anime_2.reload.cached_rates_count).to eq 1
    expect(anime_3.reload.cached_rates_count).to eq 0

    expect(manga_1.reload.cached_rates_count).to eq 2
    expect(manga_2.reload.cached_rates_count).to eq 0
  end
end
