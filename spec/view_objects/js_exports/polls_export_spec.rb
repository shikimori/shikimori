describe JsExports::PollsExport do
  let(:tracker) { described_class.instance }

  let(:poll) { build_stubbed :poll }

  before { tracker.send :cleanup }
  after { tracker.send :cleanup }

  describe '#placeholder' do
    subject { tracker.placeholder poll }
    it { is_expected.to eq poll.id.to_s }
  end

  describe '#sweep' do
    let(:html) do
      <<-HTML.strip
        <div data-track_poll="1"></div>
        <div data-track_poll="2"></div>
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
      tracker.send :track, poll_1.id
      tracker.send :track, poll_2.id
      tracker.export user
    end

    let(:poll_1) { create :poll, :pending }
    let(:poll_2) { create :poll, :started, :with_variants }

    subject { tracker.export user }

    it do
      is_expected.to eq [
        PollSerializer.new(poll_1, scope: user).to_hash,
        PollSerializer.new(poll_2, scope: user).to_hash
      ]
    end
  end
end
