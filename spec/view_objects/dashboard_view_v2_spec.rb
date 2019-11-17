describe DashboardViewV2 do
  include_context :view_object_warden_stub

  let(:view) { DashboardViewV2.new }

  # describe '#collection_topic_views' do
  #   let!(:collection) { create :collection, :with_topics }
  #   it { expect(view.collection_topic_views).to have(1).item }
  # end
  #
  # describe '#review_topic_views' do
  #   let!(:review) { create :review, :with_topics }
  #   it { expect(view.review_topic_views).to have(1).item }
  # end
  #
  # describe '#contests' do
  #   let!(:contest_1) { create :contest, :created }
  #   let!(:contest_2) { create :contest, :started }
  #   let!(:contest_3) { create :contest, :finished }
  #
  #   it { expect(view.contests).to eq [contest_2] }
  # end

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
end
