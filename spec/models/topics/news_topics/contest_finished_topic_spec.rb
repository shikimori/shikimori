describe Topics::NewsTopics::ContestFinishedTopic do
  describe 'instance methods' do
    let(:topic) { build :contest_finished_topic }

    describe '#title' do
      it { expect(topic.title).to eq 'Опрос завершён' }
    end
  end
end
