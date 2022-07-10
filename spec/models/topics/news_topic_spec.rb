describe Topics::NewsTopic do
  describe 'enumerize' do
    it { is_expected.to enumerize(:action).in :anons, :ongoing, :released, :episode }
  end

  describe 'instance methods' do
    describe '#title' do
      let(:topic) { build :news_topic, generated: generated, action: action, title: '123', value: '1' }
      let(:action) { nil }
      subject { topic.title }

      context 'generated' do
        let(:generated) { true }

        context 'episode news topic' do
          let(:action) { 'episode' }
          it { is_expected.to eq 'Эпизод 1' }
        end

        context 'anons news topic' do
          let(:topic) { build :news_topic, :anime_anons }
          it { is_expected.to eq 'Анонс' }
        end

        context 'another news topic' do
          let(:action) { 'ongoing' }
          it { is_expected.to eq 'Онгоинг' }
        end
      end

      context 'not generated' do
        let(:generated) { false }
        it { is_expected.to eq '123' }
      end
    end

    describe '#full_title' do
      context 'generated' do
        let(:anime) { create :anime }
        let(:topic) { build :news_topic, :anime_anons, linked: anime }
        it { expect(topic.full_title).to eq "Анонс аниме #{anime.name}" }
      end

      context 'not generated' do
        let(:topic) { build :news_topic, generated: false }
        it { expect(topic.full_title).to eq topic.title }
      end
    end

    describe '#accept' do
      include_context :timecop
      subject! { topic.accept }

      let(:topic) { create :news_topic, forum_id: Forum::PREMODERATION_ID }

      it do
        expect(topic).to_not be_changed
        expect(topic.forum_id).to eq Forum::NEWS_ID
        expect(topic.created_at).to be_within(0.1).of Time.zone.now
      end
    end

    describe '#reject' do
      # include_context :timecop
      subject! { topic.reject }

      let(:topic) { create :news_topic, forum_id: Forum::PREMODERATION_ID }

      it do
        expect(topic).to_not be_changed
        expect(topic.forum_id).to eq Forum::OFFTOPIC_ID
        # expect(topic.created_at).to be_within(0.1).of Time.zone.now
      end
    end

    describe '#moderation_state, #may_accept?, #may_reject?, #moderation_accepted?' do
      let(:topic) { build :news_topic, forum_id: forum_id }

      context 'Forum::PREMODERATION_ID' do
        let(:forum_id) { Forum::PREMODERATION_ID }
        it do
          expect(topic).to be_may_accept
          expect(topic).to be_may_reject
          expect(topic).to_not be_moderation_accepted
          expect(topic.moderation_state).to eq Types::Moderatable::State[:pending]
        end
      end

      context 'Forum::NEWS_ID' do
        let(:forum_id) { Forum::NEWS_ID }
        it do
          expect(topic).to_not be_may_accept
          expect(topic).to be_may_reject
          expect(topic).to be_moderation_accepted
          expect(topic.moderation_state).to eq Types::Moderatable::State[:accepted]
        end
      end

      context 'Forum::OFFTOPIC_ID' do
        let(:forum_id) { Forum::OFFTOPIC_ID }
        it do
          expect(topic).to be_may_accept
          expect(topic).to_not be_may_reject
          expect(topic).to_not be_moderation_accepted
          expect(topic.moderation_state).to eq Types::Moderatable::State[:rejected]
        end
      end
    end

    describe '#offtopic?' do
      let(:topic) { create :news_topic, forum_id: Forum::OFFTOPIC_ID }
      it do
        expect(topic.offtopic?).to eq true
      end
    end
  end
end
