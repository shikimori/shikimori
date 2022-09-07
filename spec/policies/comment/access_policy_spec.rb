describe Comment::AccessPolicy do
  subject { described_class.allowed? comment, decorated_user }

  let(:comment) { build_stubbed :comment, commentable: commentable }
  let(:decorated_user) { [user.decorate, nil].sample }
  before do
    allow(Topic::AccessPolicy)
      .to receive(:allowed?)
      .with(commentable, decorated_user)
      .and_return is_allowed
  end
  let(:is_allowed) { [true, false].sample }

  context 'no commentable topic' do
    let(:commentable) { user_2 }
    it { is_expected.to eq true }
  end

  context 'commentable topic' do
    let(:commentable) { build_stubbed :topic }
    it { is_expected.to eq is_allowed }
  end
end
