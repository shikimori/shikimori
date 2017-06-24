describe Topics::NewsTopics::ContestStartedTopic do
  describe 'instance methods' do
    let(:topic) { build :contest_started_topic }

    describe '#title' do
      it { expect(topic.title).to eq 'Опрос запущен' }
    end
  end
end
