describe Tags::FetchCoubTags do
  let(:service) { described_class.new }

  before do
    allow(service).to receive(:franchises).and_return franchises
    allow(service)
      .to receive_message_chain(:config, :added_tags)
      .and_return added_tags
    allow(service)
      .to receive_message_chain(:config, :ignored_tags)
      .and_return ignored_tags
  end
  let(:stub_download) { File.open(Rails.root.join('spec/files/coub_tags.txt.gz')) }
  let(:franchises) { %w[naruto] }
  let(:added_tags) { [] }
  let(:ignored_tags) { [] }

  subject { service.call }

  describe 'read file' do
    before do
      stub_const 'Tags::FetchCoubTags::LOCAL_GZ_PATH', '/tmp/coub_tags.txt.gz'
      stub_const 'Tags::FetchCoubTags::LOCAL_PATH', '/tmp/coub_tags.txt'
      allow(service).to receive(:download) do
        FileUtils.cp(
          Rails.root.join('spec/files/coub_tags.txt.gz'),
          described_class::LOCAL_GZ_PATH
        )
      end
    end

    it do
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

    context 'ignored tags' do
      let(:read_tags) { ['sword_art_online', 'naruto 2'] }
      let(:ignored_tags) { %w[naruto] }
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
      before { stub_const 'Tags::FetchCoubTags::MAXIMUM_TAG_SIZE', 15 }
      it { is_expected.to eq %w[naruto] }
    end

    context 'exclude short tags' do
      before { stub_const 'Tags::FetchCoubTags::MINIMUM_TAG_SIZE', 7 }
      it { is_expected.to eq %w[sword_art_online] }
    end

    context 'added tags' do
      let(:added_tags) { %w[aaaa bbbb] }
      it { is_expected.to eq %w[aaaa bbbb sword_art_online naruto] }
    end
  end
end
