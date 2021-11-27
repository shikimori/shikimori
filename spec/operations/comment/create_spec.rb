describe Comment::Create do
  include_context :timecop
  subject(:comment) { described_class.call faye, params, locale }

  let(:anime) { create :anime }
  let!(:topic) do
    create :anime_topic,
      user: user,
      linked: anime,
      locale: locale,
      updated_at: 1.hour.ago
  end

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

  # TODO: cannot pass arbitrary topic class
  #       because of limit on commentable_type in comments
  describe 'commentable' do
    context 'commentable is topic' do
      let(:commentable_id) { topic.id }
      let(:commentable_type) { Topic.name }

      it_behaves_like :comment
      it do
        expect(comment.topic).to eq topic
        expect(comment.topic.updated_at).to be_within(0.1).of(Time.zone.now)
      end
    end

    context 'commentable is user' do
      let(:commentable_id) { user.id }
      let(:commentable_type) { User.name }
      let(:is_summary) { false }
      before { allow(User::NotifyProfileCommented).to receive :call }

      it do
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

    context 'commentable is db entry' do
      context 'with topic' do
        let(:commentable_id) { anime.id }
        let(:commentable_type) { Anime.name }

        it_behaves_like :comment
        it do
          expect(subject.topic).to eq topic
          expect(subject.updated_at).to be_within(0.1).of Time.zone.now
        end
      end

      context 'with topic for different locale' do
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
          expect(subject.topic.created_at).to be_within(0.1).of Time.zone.now
          expect(subject.topic.updated_at).to be_within(0.1).of Time.zone.now
        end
      end

      context 'without topic' do
        let(:commentable_id) { anime.id }
        let(:commentable_type) { Anime.name }
        let(:topic) { nil }

        # it_behaves_like :comment
        it 'creates anime topic with specified locale' do
          expect(subject.topic).to have_attributes(
            type: Topics::EntryTopics::AnimeTopic.name,
            locale: locale.to_s
          )
          expect(subject.topic.created_at).to be_within(0.1).of Time.zone.now
          expect(subject.topic.updated_at).to be_within(0.1).of Time.zone.now
        end
      end
    end
  end
end
