describe TopicsQuery do
  include_context :seeds
  let(:query) { TopicsQuery.new nil }

  subject { query.result }

  describe '#result' do
    it { is_expected.to eq [seeded_offtopic_topic] }
  end

  describe '#by_section' do
    let!(:topic_1) { create :entry, section: anime_section, updated_at: 1.day.ago }
    let!(:topic_2) { create :entry, section: offtopic_section, updated_at: 2.days.ago }

    context 'special section: nil' do
      before { query.by_section nil }
      it { is_expected.to eq [seeded_offtopic_topic, topic_1, topic_2] }
    end

    context 'special section: reviews' do
      let!(:review) { create :review }
      before { query.by_section reviews_section }

      it { is_expected.to eq [review.thread] }
    end

    context 'special section: news' do
      let!(:news_topic) { create :anime_news }
      before { query.by_section Section.static[:news] }

      it { is_expected.to eq [news_topic] }
    end

    context 'specific section' do
      before { query.by_section anime_section }
      it { is_expected.to eq [topic_1] }
    end
  end

  describe '#by_linked' do
    let(:linked) { create :anime }
    let!(:topic_1) { create :entry, linked: linked, section: anime_section }
    let!(:topic_2) { create :entry, section: anime_section }

    before { query.by_section anime_section }
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
