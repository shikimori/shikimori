describe Comments::UserQuery do
  subject(:query) { described_class.fetch user }

  let!(:comment_1) { create :comment, user: user, body: 'zxc' }
  let!(:comment_2) { create :comment, user: user }
  let!(:comment_3) { create :comment, user: user_2 }

  it { is_expected.to eq [comment_2, comment_1] }

  describe '#search' do
    subject { query.search 'zxc' }
    it { is_expected.to eq [comment_1] }
  end

  describe '#restrictions_scope' do
    let!(:comment_1) { create :comment, user: user, commentable: public_club_topic }
    let!(:comment_2) { create :comment, user: user, commentable: private_club_topic }
    let!(:comment_3) { create :comment, user: user, commentable: shadowbanned_club_topic }

    let(:public_club_topic) { create :club_topic, linked: public_club }
    let(:private_club_topic) { create :club_topic, linked: private_club }
    let(:shadowbanned_club_topic) { create :club_topic, linked: shadowbanned_club }

    let(:public_club) { create :club }
    let(:private_club) { create :club, :private }
    let(:shadowbanned_club) { create :club, :shadowbanned }

    subject { query.restrictions_scope decorated_user }

    context 'no user' do
      let(:decorated_user) { nil }
    end

    context 'user' do
      let(:decorated_user) { user.decorate }

      context 'not club member' do
        it { is_expected.to eq [comment_1] }
      end

      context 'private club member' do
        before { user.clubs << private_club }
        it { is_expected.to eq [comment_2, comment_1] }
      end

      context 'shadowbanned club member' do
        before { user.clubs << shadowbanned_club }
        it { is_expected.to eq [comment_3, comment_1] }
      end
    end
  end

  describe '#filter_by_policy' do
    subject { query.filter_by_policy user }
    before do
      allow(Comment::AccessPolicy).to receive(:allowed?) do |comment, _user|
        comment == comment_2
      end
    end
    it { is_expected.to eq [comment_2] }
  end
end
