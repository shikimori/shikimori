describe Comment::Create do
  subject(:comment) { described_class.call faye, params, locale }

  let(:anime) { create :anime }
  let!(:topic) { create :anime_topic, user: user, linked: anime, locale: locale }

  let(:faye) { FayeService.new user, nil }
  let(:params) do
    {
      commentable_id: commentable_id,
      commentable_type: commentable_type,
      body: 'x' * Comment::MIN_SUMMARY_SIZE,
      is_offtopic: is_offtopic,
      is_summary: is_summary,
      user: user
    }
  end
  let(:is_offtopic) { [true, false].sample }
  let(:is_summary) { true }
  let(:locale) { :en }

  before { allow_any_instance_of(FayePublisher).to receive :publish }

  shared_examples_for :comment do
    it do
      expect(comment).to be_persisted
      expect(comment).to have_attributes(
        commentable_type: Topic.name,
        body: 'x' * Comment::MIN_SUMMARY_SIZE,
        is_offtopic: is_offtopic,
        is_summary: is_summary,
        user: user
      )
    end
  end

  describe 'topic' do
    # TODO: cannot pass arbitrary topic class
    #       because of limit on commentable_type in comments
    describe 'commentable' do
      context 'commentable is topic' do
        let(:commentable_id) { topic.id }
        let(:commentable_type) { Topic.name }

        it_behaves_like :comment
        its(:topic) { is_expected.to eq topic }
      end

      context 'commentable is user' do
        let(:commentable_id) { user.id }
        let(:commentable_type) { User.name }
        let(:is_summary) { false }
        before { allow(User::NotifyProfileCommented).to receive :call }

        it '', :focus do
          expect(comment).to have_attributes(
            commentable: user,
            body: 'x' * Comment::MIN_SUMMARY_SIZE,
            is_offtopic: is_offtopic,
            is_summary: false,
            user: user
          )
          expect(User::NotifyProfileCommented)
            .to have_received(:call)
            .with comment
        end
      end

      context 'commentable is review' do
        let(:review) { create :review, anime: anime }
        let(:anime) { create :anime }
        let(:commentable_id) { review.id }
        let(:commentable_type) { Review.name }
        let(:is_summary) { false }

        it do
          expect(comment).to have_attributes(
            commentable: review,
            body: 'x' * Comment::MIN_SUMMARY_SIZE,
            is_offtopic: is_offtopic,
            is_summary: false,
            user: user
          )
        end
      end
    end

    context 'commentable is db entry with topic' do
      let(:commentable_id) { anime.id }
      let(:commentable_type) { Anime.name }

      it_behaves_like :comment
      its(:topic) { is_expected.to eq topic }
    end

    context 'commentable is db entry with topic for different locale' do
      let(:commentable_id) { anime.id }
      let(:commentable_type) { Anime.name }

      let(:topic_locale) { (Shikimori::DOMAIN_LOCALES - [locale]).sample }
      let(:topic) { create :anime_topic, user: user, linked: anime, locale: topic_locale }

      it_behaves_like :comment
      it 'creates anime topic with specified locale' do
        expect(subject.topic).to have_attributes(
          type: Topics::EntryTopics::AnimeTopic.name,
          locale: locale.to_s
        )
      end
    end

    context 'commentable is db entry without topic' do
      let(:commentable_id) { anime.id }
      let(:commentable_type) { Anime.name }
      let(:topic) { nil }

      it_behaves_like :comment
      it 'creates anime topic with specified locale' do
        expect(subject.topic).to have_attributes(
          type: Topics::EntryTopics::AnimeTopic.name,
          locale: locale.to_s
        )
      end
    end
  end
end
