describe BbCodes::ImgTag do
  let(:tag) { BbCodes::ImgTag.instance }
  let(:text_hash) { 'hash' }

  describe '#format' do
    subject { tag.format text, text_hash }
    let(:url) { 'http://site.com/site-url' }
    let(:text) { "[img]#{url}[/img]" }

    context 'common case' do
      it { is_expected.to eq "<a href=\"#{url}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{url.without_protocol}\" class=\"check-width\"></a>" }
    end

    context 'multiple images' do
      let(:url_2) { 'http://site.com/site-url-2' }
      let(:text) { "[img]#{url}[/img] [img]#{url_2}[/img]" }
      it { is_expected.to eq "<a href=\"#{url}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{url.without_protocol}\" class=\"check-width\"></a> <a href=\"#{url_2}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{url_2.without_protocol}\" class=\"check-width\"></a>" }
    end

    context 'with sizes' do
      let(:text) { "[img 400x500]#{url}[/img]" }
      it { is_expected.to eq "<a href=\"#{url}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{url.without_protocol}\" class=\"\" width=\"400\" height=\"500\"></a>" }
    end

    context 'with width' do
      let(:text) { "[img w=400]#{url}[/img]" }
      it { is_expected.to eq "<a href=\"#{url}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{url.without_protocol}\" class=\"\" width=\"400\"></a>" }
    end

    context 'with height' do
      let(:text) { "[img h=500]#{url}[/img]" }
      it { is_expected.to eq "<a href=\"#{url}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{url.without_protocol}\" class=\"\" height=\"500\"></a>" }
    end

    context 'with width&height' do
      let(:text) { "[img width=400 height=500]#{url}[/img]" }
      it { is_expected.to eq "<a href=\"#{url}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{url.without_protocol}\" class=\"\" width=\"400\" height=\"500\"></a>" }
    end

    context 'with class' do
      let(:text) { "[img class=zxc]#{url}[/img]" }
      it { is_expected.to eq "<a href=\"#{url}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{url.without_protocol}\" class=\"check-width zxc\"></a>" }
    end

    context 'inside url' do
      let(:link) { '/test' }
      let(:text) { "[url=#{link}][img]#{url}[/img][/url]" }
      it { is_expected.to eq "<a href=\"#{link}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{url.without_protocol}\" class=\"check-width\"></a>" }
    end
  end
end
