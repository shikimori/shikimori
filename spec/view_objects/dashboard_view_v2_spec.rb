describe DashboardViewV2 do
  include_context :view_context_stub

  let(:view) { DashboardViewV2.new }

  describe '#ongoings' do
    let!(:anons) { create :anime, :anons }
    let!(:released) { create :anime, :released }
    let!(:ongoing_1) { create :anime, :ongoing, ranked: 10, score: 8 }
    let!(:ongoing_2) { create :anime, :ongoing, ranked: 5, score: 8 }
    let!(:ongoing_3) { create :anime, :ongoing, ranked: 5, score: 7 }

    its(:ongoings) { is_expected.to eq [ongoing_2, ongoing_1] }
  end

  describe '#collections_views' do
    let!(:collection) { create :collection, :published, :with_topics }
    its(:collections_views) { is_expected.to have(1).item }
  end

  describe '#critiques_views' do
    let!(:critique) { create :critique, :with_topics }
    its(:critiques_views) { is_expected.to have(1).item }
  end

  describe '#articles_views' do
    let!(:article) { create :article, :published, :with_topics }
    its(:articles_views) { is_expected.to have(1).item }
  end

  describe '#contest_topic_views' do
    let!(:contest_1) { create :contest, :created, :with_topics }
    let!(:contest_2) { create :contest, :started, :with_topics }
    let!(:contest_3) { create :contest, :finished, :with_topics }

    it { expect(view.contest_topic_views.map(&:topic)).to eq [contest_2.maybe_topic] }
  end

  describe '#news_topic_views' do
    let!(:news_topic) { create :news_topic, generated: false }
    its(:news_topic_views) { is_expected.to have(1).item }
  end

  describe '#db_updates' do
    let!(:news_topic) { create :news_topic, :anime_anons }
    its(:db_updates) { is_expected.to have(1).item }
  end

  describe '#cache_keys' do
    its(:cache_keys) { is_expected.to be_kind_of Hash }
  end

  describe '#anime_seasons' do
    it { expect(view.anime_seasons).to have(2).items }
    it { expect(view.anime_seasons.first).to be_kind_of Titles::SeasonTitle }
  end

  describe '#manga_kinds' do
    it do
      expect(view.manga_kinds.first).to be_kind_of Titles::KindTitle
      expect(view.manga_kinds.map(&:text)).to eq %w[
        manga manhwa manhua one_shot doujin
      ]
    end
  end

  describe '#history' do
    let!(:user_history) { create :user_history, user: user, anime: create(:anime) }
    its(:history) do
      is_expected.to be_present
      is_expected.to be_kind_of Users::UserRateHistory
    end
  end
end
