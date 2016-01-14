describe Topics::Factory do
  let(:factory) { Topics::Factory.new is_preview, is_mini }
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

  describe '#build' do
    subject(:view) { factory.build topic }

    context 'common topic' do
      let(:topic) { build :entry }

      it { expect(view).to be_a Topics::View }
      it { expect(view.is_preview).to eq false }

      context 'preview' do
        let(:is_preview) { true }
        it { expect(view.is_preview).to eq true }
      end
    end

    context 'review' do
      let(:topic) { build :review_topic }
      it { expect(view).to be_a Topics::ReviewView }
    end

    context 'cosplay' do
      let(:topic) { build :cosplay_gallery_topic }
      it { expect(view).to be_a Topics::CosplayView }
    end

    context 'contest' do
      let(:topic) { build :contest_topic, linked: build_stubbed(:contest) }
      it { expect(view).to be_a Topics::ContestView }
    end

    context 'anime news' do
      context 'generated' do
        let(:topic) { build :news_topic, generated: true }
        it { expect(view).to be_a Topics::GeneratedNewsView }
      end

      context 'not generated' do
        let(:topic) { build :news_topic, generated: false }
        it { expect(view).to be_a Topics::View }
      end
    end
  end
end
