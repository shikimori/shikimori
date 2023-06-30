describe Tags::CleanupForumTag do
  subject { described_class.call token }
  let(:token) { ['#anime', '#аниме', '#Аниме'].sample }

  it { is_expected.to eq 'аниме' }
end
