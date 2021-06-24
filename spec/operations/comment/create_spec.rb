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
      is_offtopic: true,
      is_summary: true,
      user: user
    }
  end
  let(:locale) { :en }

  before { allow_any_instance_of(FayePublisher).to receive :publish }

  shared_examples_for :comment do
    it do
      expect(comment).to be_persisted
      expect(comment).to have_attributes(
        commentable_type: Topic.name,
        body: 'x' * Comment::MIN_SUMMARY_SIZE,
        is_offtopic: true,
        is_summary: true,
        user: user
      )
    end
  end

  describe 'topic' do
    subject { comment.topic }

    # TODO: cannot pass arbitrary topic class
    #       because of limit on commentable_type in comments
    context 'commentable is topic' do
      let(:commentable_id) { topic.id }
      let(:commentable_type) { Topic.name }

      it_behaves_like :comment
      it { is_expected.to eq topic }
    end

    context 'commentable is user' do
      let(:commentable_id) { user.id }
      let(:commentable_type) { User.name }

      it do
        expect(comment).to have_attributes(
          commentable: user,
          body: 'x' * Comment::MIN_SUMMARY_SIZE,
          is_offtopic: true,
          is_summary: true,
          user: user
        )
      end
    end

    context 'commentable is db entry with topic' do
      let(:commentable_id) { anime.id }
      let(:commentable_type) { Anime.name }

      it_behaves_like :comment
      it { is_expected.to eq topic }
    end

    context 'commentable is db entry with topic for different locale' do
      let(:commentable_id) { anime.id }
      let(:commentable_type) { Anime.name }

      let(:topic_locale) { (Shikimori::DOMAIN_LOCALES - [locale]).sample }
      let(:topic) { create :anime_topic, user: user, linked: anime, locale: topic_locale }

      it_behaves_like :comment
      it 'creates anime topic with specified locale' do
        is_expected.to have_attributes(
          type: Topics::EntryTopics::AnimeTopic.name,
          locale: locale.to_s
        )
      end
    end

    context 'commentable is db entry without topic' do
      let(:commentable_id) { anime.id }
      let(:commentable_type) { Anime.name }
      let(:topic) {}

      it_behaves_like :comment
      it 'creates anime topic with specified locale' do
        is_expected.to have_attributes(
          type: Topics::EntryTopics::AnimeTopic.name,
          locale: locale.to_s
        )
      end
    end
  end
end
