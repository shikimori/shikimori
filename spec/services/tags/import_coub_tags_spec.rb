describe Tags::ImportCoubTags do
  let(:service) { described_class.new }

  before do
    stub_const 'Tags::ImportCoubTags::LOCAL_GZ_PATH', '/tmp/coub_tags.txt.gz'
    stub_const 'Tags::ImportCoubTags::LOCAL_PATH', '/tmp/coub_tags.txt'

    allow(service).to receive(:download) do
      FileUtils.cp(
        Rails.root.join('spec/files/coub_tags.txt.gz'),
        described_class::LOCAL_GZ_PATH
      )
    end
  end
  let(:stub_download) { File.open(Rails.root.join('spec/files/coub_tags.txt.gz')) }

  subject { service.call }

  context 'no tags present' do
    it do
      expect { subject }.to change(CoubTag, :count).by 2
      is_expected.to eq %w[sword_art_online naruto]
    end
  end

  context 'some tags present' do
    let!(:coub_tag) { create :coub_tag, name: 'naruto' }
    it do
      expect { subject }.to change(CoubTag, :count).by 1
      is_expected.to eq %w[sword_art_online]
    end
  end
end
