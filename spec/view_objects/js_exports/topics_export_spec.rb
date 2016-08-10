describe JsExports::TopicsExport do
  let(:tracker) { JsExports::TopicsExport.instance }
  let(:entry) { build_stubbed :topic }

  before { tracker.send :cleanup }
  after { tracker.send :cleanup }

  describe '#placeholder' do
    subject { tracker.placeholder entry }
    it { is_expected.to eq entry.id.to_s }
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
      tracker.send :track, entry_1.id
      tracker.send :track, entry_2.id
      tracker.export user_1
    end

    let(:entry_1) { create :topic }
    let(:entry_2) { create :topic }

    let(:user_1) { create :user }
    let(:user_2) { create :user }

    let!(:entry_view_1) { create :entry_view, entry: entry_1, user: user_1 }
    let!(:entry_view_2) { create :entry_view, entry: entry_2, user: user_2 }

    let(:export_1) { tracker.export user_1 }
    let(:export_2) { tracker.export user_2 }

    it do
      expect(export_1).to eq [
        { id: entry_1.id, is_viewed: true },
        { id: entry_2.id, is_viewed: false }
      ]
      expect(export_2).to eq [
        { id: entry_1.id, is_viewed: false },
        { id: entry_2.id, is_viewed: true }
      ]
    end
  end
end
