describe Moderation::VersionsItemTypeQuery do
  subject { described_class.fetch(type).sort_by(&:id) }

  let(:anime) { create :anime }
  let(:manga) { create :manga }
  let(:video) { create :video }

  let!(:version_1) { create :version, item: anime, item_diff: { russian: %w[a b] } }
  let!(:version_2) { create :version, item: manga, item_diff: { description_ru: ['1', '2'] } }
  let!(:version_3) do
    create :version,
      item: anime,
      item_diff: {
        episodes: [1, 2],
        desynced: [1, 2],
        image: [1, 2]
      }
  end
  let!(:version_4) { create :version, item: manga, item_diff: { fansubbers: %w[a b] } }
  let!(:version_5) { create :role_version, item: user }
  let!(:version_6) { create :version, item: video, item_diff: { name: %w[a b] } }

  context 'all_content' do
    let(:type) { 'all_content' }
    it { is_expected.to eq [version_1, version_2, version_3, version_4, version_6] }
  end

  context 'texts' do
    let(:type) { 'texts' }
    it { is_expected.to eq [version_2] }
  end

  context 'names' do
    let(:type) { 'names' }
    it { is_expected.to eq [version_1] }
  end

  context 'content' do
    let(:type) { 'content' }
    it { is_expected.to eq [version_3, version_6] }
  end

  context 'fansub' do
    let(:type) { 'fansub' }
    it { is_expected.to eq [version_4] }
  end

  context 'role' do
    let(:type) { 'role' }
    it { is_expected.to eq [version_5] }
  end

  context 'unknown type' do
    let(:type) { 'zxc' }
    it { expect { subject }.to raise_error Dry::Types::ConstraintError }
  end
end
