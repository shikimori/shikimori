describe BbCodes::UrlTag do
  subject { BbCodes::UrlTag.instance.format text }

  describe '#format' do
    let(:url) { 'http://site.com/site-url' }

    context 'without text' do
      let(:text) { "[url]#{url}[/url]" }
      it { should eq "<a href=\"#{url}\">site.com</a>" }
    end

    context 'with text' do
      let(:text) { "[url=#{url}]text[/url]" }
      it { should eq "<a href=\"#{url}\">text</a>" }
    end

    context 'just link' do
      context 'common case' do
        let(:text) { url }
        it { should eq "<a href=\"#{url}\">site.com</a>" }
      end

      context 'with format' do
        let(:text) { "#{url}.json" }
        it { should eq "<a href=\"#{url}.json\">site.com</a>" }
      end

      context 'space format' do
        let(:text) { "#{url} test" }
        it { should eq "<a href=\"#{url}\">site.com</a> test" }
      end

      context 'with dot' do
        let(:text) { "#{url}." }
        it { should eq "<a href=\"#{url}\">site.com</a>." }
      end

      context 'in tag' do
        let(:text) { "[zz]#{url}[/zz]" }
        it { should eq "[zz]#{url}[/zz]" }
      end
    end
  end
end
