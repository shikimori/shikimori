describe BbCodes::Tags::Html5VideoTag do
  subject!(:html) { BbCodes::Tags::Html5VideoTag.instance.format text }

  describe '#format' do
    let(:url) { 'http://html5demos.com/assets/dizzy.webm' }
    let(:text) { "[html5_video]#{url}[/html5_video]" }
    let(:webm_video) { WebmVideo.first }

    it do
      expect(WebmVideo).to have(1).item
      expect(webm_video).to have_attributes(
        state: 'pending',
        url: url
      )
      expect(html).to eq <<-HTML.squish
        <div class="b-video fixed">
          <div class="video-link">
            <img class="to-process" data-dynamic="html5_video"
              src="#{BbCodes::Tags::Html5VideoTag::DEFAULT_THUMBNAIL_NORMAL}"
              srcset="#{BbCodes::Tags::Html5VideoTag::DEFAULT_THUMBNAIL_RETINA} 2x"
              data-src="#{webm_video.thumbnail.url :normal}"
              data-srcset="#{webm_video.thumbnail.url :retina} 2x"
              data-video="#{webm_video.url}"
            />
          </div>
          <a class="marker" href="#{webm_video.url}">html5</a>
        </div>
      HTML
    end

    context 'xss' do
      let(:text) { "[html5_video]#{%w[< > " '].sample}[/html5_video]" }
      it { is_expected.to eq text }
    end
  end
end
