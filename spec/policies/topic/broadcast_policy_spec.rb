describe Topic::BroadcastPolicy do
  subject(:policy) { described_class.new topic }
  let(:topic) do
    create :topic,
      broadcast: broadcast,
      processed: processed,
      generated: generated
  end

  let(:broadcast) { false }
  let(:processed) { false }
  let(:generated) { false }

  describe '#required?' do
    it { is_expected.to_not be_required }

    context 'broadcast' do
      let(:broadcast) { true }
      it { is_expected.to be_required }

      context 'not broadcast change' do
        before { topic.update body: 'zxc' }
        it { is_expected.to_not be_required }
      end

      context 'already processed topic' do
        let(:processed) { true }
        it { is_expected.to_not be_required }
      end
    end

    context 'generated news topic' do
      let(:topic) do
        create :news_topic,
          processed: processed,
          generated: generated
      end
      let(:generated) { true }

      it { is_expected.to be_required }

      context 'not generated change' do
        before { topic.update body: 'zxc' }
        it { is_expected.to_not be_required }
      end

      context 'already processed topic' do
        let(:processed) { true }
        it { is_expected.to_not be_required }
      end

      context 'not generated topic' do
        let(:generated) { false }
        it { is_expected.to_not be_required }
      end
    end
  end
end
