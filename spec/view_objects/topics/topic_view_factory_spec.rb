describe Topics::TopicViewFactory do
  let(:factory) { Topics::TopicViewFactory.new is_preview, is_mini }
  let(:is_preview) { false }
  let(:is_mini) { false }

  describe '#find' do
    let(:topic) { create :topic }
    subject(:view) { factory.find topic.id }

    context 'common topic' do
      context 'not preview' do
        let(:is_preview) { false }
        it { expect(view).to be_a Topics::View }
        it { expect(view.is_preview).to eq false }
      end

      context 'preview' do
        let(:is_preview) { true }
        it { expect(view.is_preview).to eq true }
      end
    end
  end

  describe '#find_by' do
    let(:topic) { create :topic }
    subject(:view) { factory.find_by id: topic_id }

    context 'missing topic' do
      let(:topic_id) { 999999 }
      it { expect(view).to be_nil }
    end

    context 'common topic' do
      let(:topic_id) { topic.id }

      context 'not preview' do
        let(:is_preview) { false }
        it { expect(view).to be_a Topics::View }
        it { expect(view.is_preview).to eq false }
      end

      context 'preview' do
        let(:is_preview) { true }
        it { expect(view.is_preview).to eq true }
      end
    end
  end

  describe '#build' do
    subject(:view) { factory.build topic }

    context 'common topic' do
      let(:topic) { build :topic }

      it { expect(view).to be_a Topics::View }
      it { expect(view.is_preview).to eq false }

      context 'preview' do
        let(:is_preview) { true }
        it { expect(view.is_preview).to eq true }
      end
    end

    context 'review' do
      let(:topic) { build :review_topic }
      it { expect(view).to be_a Topics::CritiqueView }
    end

    context 'cosplay' do
      let(:topic) { build :cosplay_gallery_topic }
      it { expect(view).to be_a Topics::CosplayView }
    end

    context 'contest' do
      let(:topic) { build :contest_topic }
      it { expect(view).to be_a Topics::ContestView }
    end

    context 'contest_status' do
      let(:topic) { build :contest_status_topic }
      it { expect(view).to be_a Topics::ContestStatusView }
    end

    context 'anime news topic' do
      context 'generated' do
        let(:topic) { build :news_topic, generated: true }
        it { expect(view).to be_a Topics::GeneratedNewsView }
      end

      context 'not generated' do
        let(:topic) { build :news_topic, generated: false }
        it { expect(view).to be_a Topics::View }
      end
    end

    context 'club_page' do
      let(:topic) { build :club_page_topic }
      it { expect(view).to be_a Topics::ClubPageView }
    end

    context 'collection' do
      let(:topic) { build :collection_topic }
      it { expect(view).to be_a Topics::CollectionView }
    end
  end
end
