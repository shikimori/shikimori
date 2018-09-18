describe Moderation::VersionsItemTypeQuery do
  subject { described_class.call type }

  let!(:version_1) { create :version, item: create(:anime) }
  let!(:version_2) { create :version, item: create(:manga) }
  let!(:version_3) { create :version, item: create(:anime_video) }
  let!(:version_4) { create :role_version, item: user }

  context 'content' do
    let(:type) { 'content' }
    it { is_expected.to eq [version_1, version_2] }
  end

  context 'anime_video' do
    let(:type) { 'anime_video' }
    it { is_expected.to eq [version_3] }
  end

  context 'role' do
    let(:type) { 'role' }
    it { is_expected.to eq [version_4] }
  end

  context 'unknown type' do
    let(:type) { 'zxc' }
    it { expect { subject }.to raise_error Dry::Types::ConstraintError }
  end
end
