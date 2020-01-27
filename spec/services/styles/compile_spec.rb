describe Styles::Compile do
  subject { described_class.call css }

  context '#strip_comments' do
    let(:css) { '/* test */ test' }
    it do
      is_expected.to eq(
        imports: [],
        compiled_css: "#{described_class::MEDIA_QUERY_CSS} { test }"
      )
    end
  end

  context '#camo_images' do
    let(:image_url) { 'http://s8.hostingkartinok.com/uploads/images/2016/02/87303db8016e56e8a9eeea92f81f5760.jpg' }
    let(:css) { "body { background: url(#{quote}#{image_url}#{quote})#{suffix} };" }

    quotes = [
      '"',
      "'",
      '`',
      ''
    ]
    suffixes = [
      ', test',
      ' ;',
      ';',
      '',
      '!important',
      ' !important',
      ' !important;'
    ]

    quotes.each do |quote_value|
      describe "quote `#{quote_value}`" do
        let(:quote) { quote_value }

        suffixes.each do |suffix_value|
          let(:suffix) { suffix_value }

          describe "suffix `#{suffix_value}`" do
            it do
              is_expected.to eq(
                imports: [],
                compiled_css: <<-CSS.squish
                  #{described_class::MEDIA_QUERY_CSS} {
                    body {
                      background: url(#{quote}#{UrlGenerator.instance.camo_url image_url}#{quote})#{suffix}
                    };
                  }
                CSS
              )
            end
          end
        end
      end
    end
  end

  context '#sanitize' do
    let(:css) { 'body { color: red; }; javascript:blablalba;;' }
    it do
      is_expected.to eq(
        imports: [],
        compiled_css: "#{described_class::MEDIA_QUERY_CSS} { body { color: red; }; :blablalba; }"
      )
    end
  end

  describe '#media_query' do
    context 'with styles' do
      context 'with media' do
        let(:css) { '@media only screen and (min-width: 100px) { test }' }
        it do
          is_expected.to eq(
            imports: [],
            compiled_css: css
          )
        end
      end

      context 'without media' do
        let(:css) { 'test' }
        it do
          is_expected.to eq(
            imports: [],
            compiled_css: "#{described_class::MEDIA_QUERY_CSS} { test }"
          )
        end

        context 'with multiple imports', :vcr do
          let(:css) do
            <<~CSS
              @import url('https://thiaya.github.io/1//shi.Modern.css');
              @import url('https://thiaya.github.io/1/shi.Modern.css');
              zxc
            CSS
          end

          it do
            is_expected.to eq(
              imports: [
                'https://thiaya.github.io/1//shi.Modern.css',
                'https://thiaya.github.io/1/shi.Modern.css'
              ],
              compiled_css: "/* https://thiaya.github.io/1//shi.Modern.css */\nz\n\n/* https://thiaya.github.io/1/shi.Modern.css */\nx\n\n#{described_class::MEDIA_QUERY_CSS} { zxc }"
            )
          end
        end
      end
    end

    context 'without styles' do
      let(:css) { '' }
      it do
        is_expected.to eq(
          imports: [],
          compiled_css: ''
        )
      end
    end
  end
end
