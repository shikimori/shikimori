describe Topics::EntryTopic do
  describe 'instance methods' do
    let(:topic) { build :club_topic, linked: linked }
    let(:linked) { build_stubbed :club }

    describe '#title' do
      it { expect(topic.title).to eq 'Обсуждение клуба' }
    end

    describe '#full_title' do
      context 'generated' do
        let(:linked) { create :club }
        it { expect(topic.full_title).to eq "Обсуждение клуба #{linked.name}" }
      end

      context 'not generated' do
        let(:topic) { build :club_topic, generated: false }
        it { expect(topic.full_title).to eq topic.title }
      end
    end

    describe '#body' do
      it { expect(topic.body).to eq "Топик обсуждения [club=#{topic.linked_id}]клуба[/club]." }
    end
  end
end
