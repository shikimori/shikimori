describe Topics::NewsTopics::ContestStatusTopic do
  describe 'instance methods' do
    let(:topic) { build :contest_status_topic, action: action, linked: contest }
    let(:contest) { build :contest, title_ru: 'Тест', title_en: 'Test' }

    describe '#title & #full_title' do
      context 'started' do
        let(:action) { Types::Topic::ContestStatusTopic::Action[:started] }
        it { expect(topic.title).to eq 'Старт турнира' }
        it { expect(topic.full_title).to eq 'Старт турнира Тест' }
      end

      context 'finished' do
        let(:action) { Types::Topic::ContestStatusTopic::Action[:finished] }
        it { expect(topic.title).to eq 'Завершение турнира' }
        it { expect(topic.full_title).to eq 'Завершение турнира Тест' }
      end
    end
  end
end
