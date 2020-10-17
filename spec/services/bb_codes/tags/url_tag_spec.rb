describe BbCodes::Tags::UrlTag do
  subject { described_class.instance.format text }

  let(:rel) { 'rel="noopener noreferrer nofollow"' }
  let(:url) { 'http://site.com/site-url?a=1&b=2' }
  let(:escaped_url) { ERB::Util.h url }

  context 'without text' do
    let(:text) { "[url]#{escaped_url}[/url]" }

    it do
      is_expected.to eq(
        "<a class=\"b-link\" href=\"#{url}\" #{rel}>#{Url.new(url).without_http}</a>"
      )
    end

    context 'with class' do
      let(:text) { "[url aa bb]#{escaped_url}[/url]" }
      it do
        is_expected.to eq(
          "<a class=\"b-link aa bb\" href=\"#{url}\" #{rel}>#{Url.new(url).without_http}</a>"
        )
      end
    end

    context 'wo protocol url' do
      let(:url) { '//site.com/site-url?a=1&b=2' }
      let(:text) { "[url]#{escaped_url}[/url]" }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"#{url}\" #{rel}>#{Url.new(url).without_http}</a>"
        )
      end
    end

    context 'long url' do
      let(:url) { 'http://site.com/' + ('x' * BbCodes::Tags::UrlTag::MAX_SHORT_URL_SIZE) }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"#{url}\" #{rel}>site.com</a>"
        )
      end
    end

    context 'shikimori url' do
      let(:url) { '//shikimori.test/animes' }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"#{url}\" #{rel}>/animes</a>"
        )
      end
    end

    context 'encoded url' do
      let(:url) { '//shikimori.test/%D0%92%D0%B8%D0%BD%D0%BD%D0%B8' }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"#{url}\" #{rel}>/Винни</a>"
        )
      end
    end

    context 'webm url tag' do
      let(:url) { 'http://html5demos.com/assets/dizzy.webm' }
      it { is_expected.to eq '[html5_video]http://html5demos.com/assets/dizzy.webm[/html5_video]' }
    end

    context 'mp4 url tag' do
      let(:url) { 'http://media.w3.org/2010/05/sintel/trailer.mp4' }
      it { is_expected.to eq '[html5_video]http://media.w3.org/2010/05/sintel/trailer.mp4[/html5_video]' }
    end

    context 'webm url' do
      let(:text) { 'http://html5demos.com/assets/dizzy.webm' }
      it { is_expected.to eq '[html5_video]http://html5demos.com/assets/dizzy.webm[/html5_video]' }
    end

    context 'xss' do
      let(:text) { "[url]#{%w[< > " '].sample}[/url]" }
      it { is_expected.to eq text }
    end

    context 'some shiki url' do
      let(:text) { "https://shikimori.one#{path}" }
      let(:path) { '/tests/border?image_url=http://i.imgur.com/Arxun3R.gif&image_border=@ff0000' }
      it { is_expected.to eq "<a class=\"b-link\" href=\"#{path}\">#{path}</a>" }
    end
  end

  context 'with text' do
    let(:text) { "[url=#{url}]text[/url]" }

    it do
      is_expected.to eq(
        "<a class=\"b-link\" href=\"#{url}\" #{rel}>text</a>"
      )
    end

    context 'with class' do
      let(:text) { "[url=#{url} aa bb]text[/url]" }
      it do
        is_expected.to eq(
          "<a class=\"b-link aa bb\" href=\"#{url}\" #{rel}>text</a>"
        )
      end
    end

    context 'without http' do
      let(:url) { 'site.com/site-url?a=1&b=2' }
      let(:text) { "[url=#{escaped_url}]text[/url]" }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"http://#{url}\" #{rel}>text</a>"
        )
      end
    end

    describe 'relative path' do
      let(:text) { '[url=/test]test[/url]' }
      it { is_expected.to eq '<a class="b-link" href="/test">test</a>' }
    end
  end

  context 'just link' do
    context 'common case' do
      let(:text) { url }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"#{url}\" #{rel}>#{Url.new(url).without_http}</a>"
        )
      end
    end

    context 'without protocol' do
      let(:url) { '//site.com/site-url' }
      let(:text) { url }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"#{url}\" #{rel}>#{Url.new(url).without_http}</a>"
        )
      end
    end

    context 'with format' do
      let(:text) { "#{url}.json" }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"#{url}.json\" #{rel}>#{Url.new(url).without_http}.json</a>"
        )
      end
    end

    context 'space format' do
      let(:text) { "#{url} test" }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"#{url}\" #{rel}>#{Url.new(url).without_http}</a> test"
        )
      end
    end

    context 'with dot' do
      let(:text) { "#{url}." }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"#{url}\" #{rel}>#{Url.new(url).without_http}</a>."
        )
      end
    end

    context 'with comma' do
      let(:text) { "#{url}, test" }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"#{url}\" #{rel}>#{Url.new(url).without_http}</a>, test"
        )
      end
    end

    context 'with brackets' do
      let(:text) { "(#{url})" }
      it do
        is_expected.to eq(
          "(<a class=\"b-link\" href=\"#{url}\" #{rel}>#{Url.new(url).without_http}</a>)"
        )
      end
    end

    context 'with brackets #2' do
      let(:text) { "url(#{url});" }
      it do
        is_expected.to eq(
          "url(<a class=\"b-link\" href=\"#{url}\" #{rel}>#{Url.new(url).without_http}</a>);"
        )
      end
    end

    context 'in tag' do
      let(:text) { "[zz]#{url}[/zz]" }
      it { is_expected.to eq "[zz]#{url}[/zz]" }
    end

    context 'russian link' do
      let(:text) { 'http://www.hentasis.com/tags/%D3%F7%E8%F2%E5%EB%FC%ED%E8%F6%FB/' }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"http://www.hentasis.com/tags/%D3%F7%E8%F2%E5%EB%FC%ED%E8%F6%FB/\" #{rel}>www.hentasis.com</a>"
        )
      end
    end

    context 'shikimori link' do
      let(:text) { 'http://shikimori.org/zxc' }
      it { is_expected.to eq '<a class="b-link" href="/zxc">/zxc</a>' }
    end

    context 'partial shikimori link' do
      let(:text) { 'https://github.com/shikimori/shikimori/commit/f77bcc324ac6e20eeadaff9363ac71ec9c99301e' }
      it do
        is_expected.to eq(
          "<a class=\"b-link\" href=\"https://github.com/shikimori/shikimori/commit/f77bcc324ac6e20eeadaff9363ac71ec9c99301e\" #{rel}>github.com</a>"
        )
      end
    end

    # context 'broken tag' do
    #   let(:link) { '[url=https://z.org/%B0«z»' } # Zrubocop:disable Style/FormatStringToken
    #   let(:text) { "[url=#{url}]#{link}[/url]" }
    #   it { is_expected.to eq "<a class=\"b-link\" href=\"#{url}\">#{link}</a>" }
    # end
  end
end
