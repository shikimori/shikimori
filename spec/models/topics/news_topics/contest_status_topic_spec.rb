describe Topics::NewsTopics::ContestStatusTopic do
  describe 'instance methods' do
    let(:topic) { build :contest_status_topic, action: action }

    describe '#title' do
      context 'started' do
        let(:action) { Types::Topic::ContestStatusTopic::Action[:started] }
        it { expect(topic.title).to eq 'Старт опроса' }
      end

      context 'finished' do
        let(:action) { Types::Topic::ContestStatusTopic::Action[:finished] }
        it { expect(topic.title).to eq 'Завершение опроса' }
      end
    end
  end
end
