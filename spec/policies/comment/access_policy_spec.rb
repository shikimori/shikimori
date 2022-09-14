describe Comment::AccessPolicy do
  subject { described_class.allowed? comment, decorated_user }

  let(:comment) do
    build_stubbed :comment,
      user: comment_user,
      commentable: commentable
  end
  let(:decorated_user) { [user.decorate, nil].sample }
  let(:comment_user) { user_2 }
  before do
    allow(Topic::AccessPolicy)
      .to receive(:allowed?)
      .with(commentable, decorated_user)
      .and_return is_allowed
  end
  let(:is_allowed) { [true, false].sample }

  context "user's own comment" do
    let(:comment_user) { user }
    let(:decorated_user) { user.decorate }
    let(:commentable) { build_stubbed :topic }
    let(:is_allowed) { false }

    it { is_expected.to eq true }
  end

  context "other user's comment" do
    context 'no commentable topic' do
      let(:commentable) { user_2 }
      it { is_expected.to eq true }
    end

    context 'commentable topic' do
      let(:commentable) { build_stubbed :topic }
      it { is_expected.to eq is_allowed }
    end
  end
end
