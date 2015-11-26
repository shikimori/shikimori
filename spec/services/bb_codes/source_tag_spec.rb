describe BbCodes::SourceTag do
  subject { BbCodes::SourceTag.instance.format text }

  describe '#format' do
    let(:url) { 'http://site.com/site-url' }
    let(:text) { "[source]#{url}[/source]" }

    it { should eq "<div class=\"b-source hidden\"><span class=\"linkeable\" \
data-href=\"#{url}\">site.com</span></div>" }
  end
end
