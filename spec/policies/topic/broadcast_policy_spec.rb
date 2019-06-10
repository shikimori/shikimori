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
          generated: generated,
          action: action,
          created_at: created_at
      end
      let(:generated) { true }
      let(:action) { nil }
      let(:created_at) { Time.zone.now }

      it { is_expected.to be_required }

      context 'episode topic' do
        let(:created_at) { Topic::BroadcastPolicy::EPISODE_EXPIRATION_INTERVAL.ago + offset }
        let(:action) { Types::Topic::NewsTopic::Action[:episode] }

        context 'expired' do
          let(:offset) { - 1.minute }
          it { is_expected.to_not be_required }
        end

        context 'not expired' do
          let(:offset) { 1.minute }
          it { is_expected.to be_required }
        end
      end

      context 'released topic' do
        let(:created_at) { Topic::BroadcastPolicy::RELEASED_EXPIRATION_INTERVAL.ago + offset }
        let(:action) { Types::Topic::NewsTopic::Action[:released] }

        context 'expired' do
          let(:offset) { - 1.minute }
          it { is_expected.to_not be_required }
        end

        context 'not expired' do
          let(:offset) { 1.minute }
          it { is_expected.to be_required }
        end
      end

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
