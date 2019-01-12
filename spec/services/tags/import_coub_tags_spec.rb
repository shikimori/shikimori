describe Tags::ImportCoubTags do
  let(:service) { described_class.new }

  before do
    stub_const 'Tags::ImportCoubTags::LOCAL_GZ_PATH', '/tmp/coub_tags.txt.gz'
    stub_const 'Tags::ImportCoubTags::LOCAL_PATH', '/tmp/coub_tags.txt'
    stub_const 'Tags::ImportCoubTags::BATCH_SIZE', batch_size

    allow(service).to receive(:download) do
      FileUtils.cp(
        Rails.root.join('spec/files/coub_tags.txt.gz'),
        described_class::LOCAL_GZ_PATH
      )
    end
  end
  let(:stub_download) { File.open(Rails.root.join('spec/files/coub_tags.txt.gz')) }
  let(:batch_size) { 2 }
  let(:process) { double call: nil }

  subject do
    service.call do |tags|
      process.call tags
    end
  end

  context 'no tags present' do
    it do
      expect { subject }.to change(CoubTag, :count).by 2
      is_expected.to eq %w[sword_art_online naruto]
      expect(process).to have_received(:call).with %w[sword_art_online naruto]
      expect(process).to have_received(:call).once
    end

    context 'multiple batches' do
      let(:batch_size) { 1 }

      it do
        expect { subject }.to change(CoubTag, :count).by 2
        is_expected.to eq %w[sword_art_online naruto]
        expect(process).to have_received(:call).with(%w[sword_art_online]).ordered
        expect(process).to have_received(:call).with(%w[naruto]).ordered
        expect(process).to have_received(:call).twice
      end
    end
  end

  context 'some tags present' do
    let!(:coub_tag) { create :coub_tag, name: 'naruto' }
    it do
      expect { subject }.to change(CoubTag, :count).by 1
      is_expected.to eq %w[sword_art_online]
      expect(process).to have_received(:call).with %w[sword_art_online]
      expect(process).to have_received(:call).once
    end
  end
end
