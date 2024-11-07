describe Comment::AccessPolicy do
  subject { described_class.allowed? comment, current_user }

  let(:comment) do
    build_stubbed :comment,
      user: comment_user,
      commentable: commentable
  end
  let(:current_user) { [nil, user, user.decorate].sample }
  let(:comment_user) { user_2 }
  before do
    allow(Commentable::AccessPolicy)
      .to receive(:allowed?)
      .with(commentable, current_user)
      .and_return is_allowed
  end
  let(:commentable) { build_stubbed :topic }
  let(:is_allowed) { [true, false].sample }

  it { is_expected.to eq is_allowed }

  context 'own comment' do
    let(:current_user) { comment_user }
    it { is_expected.to eq true }
  end
end
