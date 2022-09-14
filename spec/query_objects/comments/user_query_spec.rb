describe Comments::UserQuery do
  subject(:query) { described_class.fetch user }

  let!(:comment) { create :comment, user: user, body: 'zxc' }
  let!(:comment_2) { create :comment, user: user }
  let!(:comment_3) { create :comment, user: user_2 }

  it { is_expected.to eq [comment_2, comment] }

  describe '#search' do
    subject { query.search 'zxc' }
    it { is_expected.to eq [comment] }
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
