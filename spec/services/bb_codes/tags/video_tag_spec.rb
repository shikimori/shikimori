describe BbCodes::Tags::VideoTag do
  subject { described_class.instance.format text }

  context 'id' do
    let(:hash) { 'hGgCnkvHLJY' }
    let(:video) { create :video, url: "http://www.youtube.com/watch?v=#{hash}" }
    let(:text) { "[video=#{video.id}]" }

    it do
      is_expected.to include(
        "data-href=\"//youtube.com/embed/#{hash}\" href=\"https://youtube.com/watch?v=#{hash}\""
      )
    end
  end

  context 'url' do
    let(:text) { "[video]#{url}[/video]" }

    context 'youtube' do
      let(:hash) { 'msY5-XBHeRg' }
      let(:url) { "https://www.youtube.com/watch?v=#{hash}" }

      it do
        is_expected.to include(
          "data-href=\"//youtube.com/embed/#{hash}\" href=\"https://youtube.com/watch?v=#{hash}\""
        )
      end
    end

    context 'vk', :vcr do
      let(:oid) { '98023184' }
      let(:vid) { '165811692' }
      let(:hash2) { '6d9a4c5f93270892' }
      let(:url) { "https://vk.com/video#{oid}_#{vid}" }

      it do
        is_expected.to include '<div class="c-video b-video unprocessed vk'
        is_expected.to include(
          "data-href=\"//vk.com/video_ext.php?oid=#{oid}&amp;id=#{vid}&amp;hash=#{hash2}\" href=\"https://vk.com/video#{oid}_#{vid}\""
        )
      end
    end
  end

  context 'broken tag' do
    let(:text) { '[video] [video]https://youtu.be/vEQeT2wxsqk[/video]' }
    it { is_expected.to include '[video] <div class="c-video' }
  end
end
