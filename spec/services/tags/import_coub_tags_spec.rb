describe Tags::ImportCoubTags do
  let(:service) { described_class.new }

  before do
    stub_const 'Tags::ImportCoubTags::BATCH_SIZE', batch_size
    allow(service).to receive(:franchises).and_return franchises
  end
  let(:stub_download) { File.open(Rails.root.join('spec/files/coub_tags.txt.gz')) }
  let(:batch_size) { 2 }
  let(:process) { double call: nil }
  let(:franchises) { %w[naruto] }

  subject { service.call }

  describe 'read file' do
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

    it do
      expect { subject }.to change(CoubTag, :count).by 2
      is_expected.to eq %w[sword_art_online naruto]
    end
  end

  context 'stub read' do
    before do
      allow(service).to receive :download
      allow(service).to receive :ungzip
      allow(service).to receive(:read_tags).and_return read_tags
    end
    let(:read_tags) { %w[sword_art_online naruto] }

    describe 'yield results' do
      subject do
        service.call do |tags|
          process.call tags
        end
      end

      context 'no tags present' do
        it do
          is_expected.to eq %w[sword_art_online naruto]
          expect(process).to have_received(:call).with %w[sword_art_online naruto]
          expect(process).to have_received(:call).once
        end

        context 'multiple batches' do
          let(:batch_size) { 1 }

          it do
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
          is_expected.to eq %w[sword_art_online]
          expect(process).to have_received(:call).with %w[sword_art_online]
          expect(process).to have_received(:call).once
        end
      end
    end

    context 'ignored tags' do
      before { allow(service).to receive(:ignored_tags).and_return %w[naruto] }
      it { is_expected.to eq %w[sword_art_online] }
    end

    context 'exclude single words' do
      let(:read_tags) do
        [
          'sword_art',
          'sword art',
          'zzz',
          'the_aaaa',
          'the_bbbb_bbb',
          'the aaaa',
          'the bbbb bbb'
        ]
      end
      it { is_expected.to eq ['sword_art', 'sword art', 'the_bbbb_bbb', 'the bbbb bbb'] }
    end

    context 'exclude long tags' do
      before { stub_const 'Tags::ImportCoubTags::MAXIMUM_TAG_SIZE', 15 }
      it { is_expected.to eq %w[naruto] }
    end

    context 'exclude short tags' do
      before { stub_const 'Tags::ImportCoubTags::MINIMUM_TAG_SIZE', 7 }
      it { is_expected.to eq %w[sword_art_online] }
    end
  end
end
