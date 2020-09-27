describe Styles::Compile do
  subject { described_class.call css }
  let(:user_note) { "/* #{described_class::USER_CONTENT} */\n" }

  context '#strip_comments' do
    let(:css) { '/* test */ a { color: red }' }
    it do
      is_expected.to eq(
        imports: [],
        compiled_css: "#{user_note}#{described_class::MEDIA_QUERY_CSS} {\na { color: red }\n}"
      )
    end
  end

  let(:image_url) { 'http://s8.hostingkartinok.com/uploads/images/2016/02/87303db8016e56e8a9eeea92f81f5760.jpg' }
  let(:camo_url) { UrlGenerator.instance.camo_url image_url }

  context '#camo_images' do
    let(:css) { "body { background: url(#{quote}#{image_url}#{quote})#{suffix} }" }

    quotes = [
      '"',
      "'",
      # '`',
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
                compiled_css: user_note + "#{described_class::MEDIA_QUERY_CSS} {\n" \
                  'body {' \
                    " background: url(#{quote}#{camo_url}#{quote})#{suffix} " \
                  "}\n" \
                '}'
              )
            end
          end
        end
      end
    end
  end

  context '#sanitize' do
    let(:css) { 'a { color: red }; javascript:blablalba;;' }
    it do
      is_expected.to eq(
        imports: [],
        compiled_css: "#{user_note}#{described_class::MEDIA_QUERY_CSS} {\na { color: red }; :blablalba;\n}"
      )
    end
  end

  describe '#media_query' do
    context 'with styles' do
      context 'with media' do
        let(:css) { user_note + '@media only screen and (min-width: 100px) { a { color: red } }' }
        it do
          is_expected.to eq(
            imports: [],
            compiled_css: css
          )
        end
      end

      context 'without media' do
        let(:css) { 'a { color: red }' }
        it do
          is_expected.to eq(
            imports: [],
            compiled_css: "#{user_note}#{described_class::MEDIA_QUERY_CSS} {\na { color: red }\n}"
          )
        end

        context 'with multiple imports', :vcr do
          let(:css) do
            <<~CSS
              @import url('https://thiaya.github.io/1/shi.Modern.css');
              @import "https://thiaya.github.io/2/shi.Modern.css";
              a { color: red; }
              /* @import url('https://thiaya.github.io/2/shi.Modern.css'); */
            CSS
          end

          it do
            is_expected.to eq(
              imports: [
                'https://thiaya.github.io/1/shi.Modern.css',
                'https://thiaya.github.io/2/shi.Modern.css'
              ],
              compiled_css: "/* https://thiaya.github.io/1/shi.Modern.css */\n" \
                "a { background: url('#{camo_url}'); }" \
                "\n\n" \
                "/* https://thiaya.github.io/2/shi.Modern.css */\n" \
                'a { color: blue; }' \
                "\n\n" \
                "#{user_note}#{described_class::MEDIA_QUERY_CSS} {\na { color: red; }\n}"
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
