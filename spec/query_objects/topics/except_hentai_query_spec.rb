describe Topics::ExceptHentaiQuery do
  subject { described_class.call scope }
  let(:scope) do
    Topic
      .where(
        id: [
          topic.id,
          anime_non_heitai_topic.id,
          anime_heitai_topic.id,
          manga_non_heitai_topic.id,
          manga_hentai_topic.id
        ]
      )
      .order(:id)
  end

  let!(:topic) { create :topic }
  let!(:anime_non_heitai_topic) { create :topic, linked: anime_non_hentai }
  let!(:anime_heitai_topic) { create :topic, linked: anime_hentai }
  let(:anime_non_hentai) { create :anime, is_censored: false }
  let(:anime_hentai) { create :anime, is_censored: true }

  let!(:manga_non_heitai_topic) { create :topic, linked: manga_non_hentai }
  let!(:manga_hentai_topic) { create :topic, linked: manga_hentai }
  let(:manga_non_hentai) { create :manga, is_censored: false }
  let(:manga_hentai) { create :manga, is_censored: true }

  it { is_expected.to eq [topic, anime_non_heitai_topic, manga_non_heitai_topic] }
end
