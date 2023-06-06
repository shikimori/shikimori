describe Moderation::VersionsItemTypeQuery do
  subject { described_class.fetch(type).sort_by(&:id) }

  let(:anime) { create :anime }
  let(:manga) { create :manga }
  let(:video) { create :video }

  let!(:version_russian) do
    create :version, item: anime, item_diff: { russian: %w[a b] }
  end
  let!(:version_description) do
    create :version, item: manga, item_diff: { description_ru: ['1', '2'] }
  end
  let!(:version_content) do
    create :version,
      item: anime,
      item_diff: {
        episodes: [1, 2],
        desynced: [1, 2],
        image: [1, 2]
      }
  end
  let!(:version_fansub) do
    create :version, item: manga, item_diff: { fansubbers: %w[a b] }
  end
  let!(:version_role) { create :role_version, item: user }
  let!(:version_video_field) do
    create :version, item: video, item_diff: { name: %w[a b] }
  end
  let!(:version_video_upload) do
    create :video_version, item: anime, item_diff: { videos: %w[a b] }
  end

  let!(:version_image) do
    create :version, item: anime, item_diff: { russian: %w[a b] }
  end
  let!(:version_external_links) do
    create :collection_version, item: anime, item_diff: { external_links: [] }
  end

  context 'all_content' do
    let(:type) { 'all_content' }
    it do
      is_expected.to eq [
        version_russian,
        version_description,
        version_content,
        version_fansub,
        version_video_field,
        version_video_upload,
        version_image,
        version_external_links
      ]
    end
  end

  context 'texts' do
    let(:type) { 'texts' }
    it { is_expected.to eq [version_description] }
  end

  context 'names' do
    let(:type) { 'names' }
    it { is_expected.to eq [version_russian] }
  end

  context 'content' do
    let(:type) { 'content' }
    it do
      is_expected.to eq [
        version_content,
        version_video_field,
        version_video_upload,
        version_image,
        version_external_links
      ]
    end
  end

  context 'fansub' do
    let(:type) { 'fansub' }
    it { is_expected.to eq [version_fansub] }
  end

  context 'videos', :focus do
    let(:type) { 'videos' }
    it { is_expected.to eq [version_video_field, version_video_upload] }
  end

  context 'images' do
    let(:type) { 'images' }
    it { is_expected.to eq [version_image] }
  end

  context 'links' do
    let(:type) { 'links' }
    it { is_expected.to eq [version_external_links] }
  end

  context 'role' do
    let(:type) { 'role' }
    it { is_expected.to eq [version_role] }
  end

  context 'unknown type' do
    let(:type) { 'zxc' }
    it { expect { subject }.to raise_error Dry::Types::ConstraintError }
  end
end
