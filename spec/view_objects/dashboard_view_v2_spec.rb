describe DashboardViewV2 do
  include_context :view_object_warden_stub

  let(:view) { DashboardViewV2.new }

  describe '#collections_views' do
    let!(:collection) { create :collection, :published, :with_topics }
    it { expect(view.collections_views).to have(1).item }
  end

  describe '#reviews_views' do
    let!(:review) { create :review, :with_topics }
    it { expect(view.reviews_views).to have(1).item }
  end

  describe '#articles_views' do
    let!(:article) { create :article, :published, :with_topics }
    it { expect(view.articles_views).to have(1).item }
  end

  describe '#contest_topic_views' do
    let!(:contest_1) { create :contest, :created, :with_topics }
    let!(:contest_2) { create :contest, :started, :with_topics }
    let!(:contest_3) { create :contest, :finished, :with_topics }

    it { expect(view.contest_topic_views.map(&:topic)).to eq [contest_2.maybe_topic(:ru)] }
  end

  describe '#news_topic_views' do
    let!(:news_topic) { create :news_topic, generated: false }
    it { expect(view.news_topic_views).to have(1).item }
  end

  describe '#db_updates' do
    let!(:news_topic) { create :news_topic, :anime_anons }
    it { expect(view.db_updates).to have(1).item }
  end

  describe '#cache_keys' do
    it { expect(view.cache_keys).to be_kind_of Hash }
  end

  describe '#anime_seasons' do
    it { expect(view.anime_seasons).to have(2).items }
    it { expect(view.anime_seasons.first).to be_kind_of Titles::SeasonTitle }
  end

  describe '#history' do
    let!(:user_history) { create :user_history, user: user, target: create(:anime) }
    it { expect(view.history).to have(1).item }
  end
end
