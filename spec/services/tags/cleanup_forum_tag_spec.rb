describe Tags::CleanupForumTag do
  subject { described_class.call token }

  context 'mapping' do
    let(:token) { ['#anime', '#анимэ', '#Аниме'].sample }
    it { is_expected.to eq 'аниме' }
  end

  context 'lattice' do
    let(:token) { 'test' }
    it { is_expected.to eq 'test' }
  end
end
