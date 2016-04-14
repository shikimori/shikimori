describe Comment::Create do
  let(:service) { Comment::Create.call faye, params }
  let(:comment) { Comment.last }

  let(:user) { create :user }
  let(:anime) { create :anime }
  let!(:topic) { create :anime_topic, user: user, linked: anime }

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

  before { allow_any_instance_of(FayePublisher).to receive :publish }
  before { service }

  shared_examples_for :comment do
    it do
      expect(comment).to have_attributes(
        commentable_type: 'Entry',
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
      let(:commentable_type) { 'Entry' }

      it_behaves_like :comment
      it { is_expected.to eq topic }
    end

    context 'commentable is db entry without topic' do
      let(:commentable_id) { anime.id }
      let(:commentable_type) { anime.class.name }
      let(:topic) {}

      it_behaves_like :comment
      it { is_expected.to be_present }
      it { is_expected.to be_kind_of Topic }
    end

    context 'commentable is db entry with topic' do
      let(:commentable_id) { anime.id }
      let(:commentable_type) { anime.class.name }

      it_behaves_like :comment
      it { is_expected.to eq topic }
    end
  end
end
