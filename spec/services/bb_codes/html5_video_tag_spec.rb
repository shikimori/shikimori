describe BbCodes::Html5VideoTag do
  subject!(:html) { BbCodes::Html5VideoTag.instance.format text }

  describe '#format' do
    let(:url) { 'http://html5demos.com/assets/dizzy.webm' }
    let(:text) { "[html5_video]#{url}[/html5_video]" }
    let(:webm_video) { WebmVideo.first }

    it do
      expect(WebmVideo).to have(1).item
      expect(webm_video).to have_attributes(
        state: 'pending',
        url: url,
      )
      expect(html).to eq "<div class=\"b-video fixed\">
  <img class=\"to-process\" data-dynamic=\"html5_video\" \
src=\"#{BbCodes::Html5VideoTag::DEFAULT_THUMBNAIL_NORMAL}\" \
srcset=\"#{BbCodes::Html5VideoTag::DEFAULT_THUMBNAIL_RETINA} 2x\" \
data-src=\"#{webm_video.thumbnail.url :normal}\" \
data-srcset=\"#{webm_video.thumbnail.url :retina} 2x\" \
data-video=\"#{webm_video.url}\" \
/>
  <a class=\"marker\" href=\"#{webm_video.url}\">html5</a>
</div>"
    end
  end
end
