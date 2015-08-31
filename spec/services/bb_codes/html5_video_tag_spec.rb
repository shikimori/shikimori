describe BbCodes::Html5VideoTag do
  subject { BbCodes::Html5VideoTag.instance.format text }

  describe '#format' do
    let(:url) { 'http://html5demos.com/assets/dizzy.webm' }
    let(:text) { "[html5_video]#{url}[/html5_video]" }

    it { should eq "<div class=\"b-video fixed\">
  <img class=\"to-process\" data-dynamic=\"html5_video\" src=\"/assets/globals/html5_video.png\" srcset=\"/assets/globals/html5_video@2x.png 2x\" data-video=\"#{url}\" />
  <a class=\"marker\" href=\"#{url}\">html5</a>
</div>" }
  end
end
