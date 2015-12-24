describe TopicsQuery do
  include_context :seeds
  let(:query) { TopicsQuery.new user }

  subject { query.result }

  describe '#result' do
    it { is_expected.to eq [seeded_offtopic_topic] }
  end

  describe '#by_forum' do
    let!(:review) { create :review, created_at: 3.days.ago }
    let!(:anime_topic) { create :entry, forum: animanga_forum, updated_at: 1.day.ago }
    let!(:offtop_topic) { create :entry, forum: offtopic_forum, updated_at: 2.days.ago }

    context 'not specified: default' do
      before do
        user.preferences.forums = forums if user
        query.by_forum nil
      end

      context 'guest' do
        let(:user) { nil }
        it { is_expected.to eq [seeded_offtopic_topic, anime_topic, offtop_topic] }
      end

      context 'all forums' do
        let(:forums) { [offtopic_forum.id, animanga_forum.id] }
        it { is_expected.to eq [seeded_offtopic_topic, anime_topic, offtop_topic] }
      end

      context 'specific forums' do
        let(:forums){ [animanga_forum.id] }
        it { is_expected.to eq [anime_topic] }
      end
    end

    context 'special forum: reviews' do
      before { query.by_forum reviews_forum }

      it { is_expected.to eq [review.thread] }
    end

    # context 'special forum: news' do
      # let!(:news_topic) { create :anime_news }
      # before { query.by_forum Forum.static[:news] }

      # it { is_expected.to eq [news_topic] }
    # end

    context 'specific forum' do
      before { query.by_forum animanga_forum }
      it { is_expected.to eq [anime_topic] }
    end
  end

  describe '#by_linked' do
    let(:linked) { create :anime }
    let!(:topic_1) { create :entry, linked: linked, forum: animanga_forum }
    let!(:topic_2) { create :entry, forum: animanga_forum }

    before { query.by_forum animanga_forum }
    before { query.by_linked linked }

    it { is_expected.to eq [topic_1] }
  end

  describe '#as_views' do
    let(:is_preview) { true }
    let(:is_mini) { true }

    subject(:views) { query.as_views is_preview, is_mini }

    it do
      expect(views).to have(1).item
      expect(views.first).to be_kind_of Topics::View
      expect(views.first.is_mini).to eq true
      expect(views.first.is_preview).to eq true
    end

    context 'preview' do
      let(:is_preview) { false }
      it do
        expect(views.first.is_mini).to eq true
        expect(views.first.is_preview).to eq false
      end
    end

    context 'mini' do
      let(:is_mini) { false }
      it do
        expect(views.first.is_mini).to eq false
        expect(views.first.is_preview).to eq true
      end
    end
  end
end
