describe JsExports::TopicsExport do
  let(:tracker) { described_class.instance }
  let(:topic) { build_stubbed :topic }

  before { tracker.send :cleanup }
  after { tracker.send :cleanup }

  describe '#placeholder' do
    subject { tracker.placeholder topic }
    it { is_expected.to eq topic.id.to_s }
  end

  describe '#sweep' do
    let(:html) do
      <<-HTML.strip
        <div data-track_topic="1"></div>
        <div data-track_topic="2"></div>
      HTML
    end
    before { tracker.send :track, 3 }
    subject! { tracker.sweep html }

    it do
      is_expected.to eq html
      expect(tracker.send :tracked_ids).to eq [1, 2]
    end
  end

  describe '#export' do
    before do
      tracker.send :track, topic_1.id
      tracker.send :track, topic_2.id
      tracker.export user_1
    end

    let(:topic_1) { create :topic }
    let(:topic_2) { create :topic }

    let(:user_1) { create :user }
    let(:user_2) { create :user }

    let!(:topic_viewing_1) do
      create :topic_viewing, viewed: topic_1, user: user_1
    end
    let!(:topic_viewing_2) do
      create :topic_viewing, viewed: topic_2, user: user_2
    end

    let(:export_1) { tracker.export user_1 }
    let(:export_2) { tracker.export user_2 }

    it do
      expect(export_1).to eq [{
        can_destroy: false,
        can_edit: false,
        id: topic_1.id,
        is_viewed: true,
        user_id: topic_1.user_id
      }, {
        can_destroy: false,
        can_edit: false,
        id: topic_2.id,
        is_viewed: false,
        user_id: topic_2.user_id
      }]
      expect(export_2).to eq [{
        can_destroy: false,
        can_edit: false,
        id: topic_1.id,
        is_viewed: false,
        user_id: topic_1.user_id
      }, {
        can_destroy: false,
        can_edit: false,
        id: topic_2.id,
        is_viewed: true,
        user_id: topic_2.user_id
      }]
    end
  end
end
