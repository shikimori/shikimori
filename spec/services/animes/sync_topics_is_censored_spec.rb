describe Animes::SyncTopicsIsCensored do
  let(:anime) { build_stubbed :anime, is_censored: is_censored }
  let(:is_censored) { false }
  let!(:anime_topic) do
    create :anime_topic, linked: anime, is_censored: !is_censored
  end

  subject! { described_class.call anime }

  it do
    expect(anime_topic.reload.is_censored).to eq is_censored
  end
end
