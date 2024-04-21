describe Styles::Compile do
  subject { described_class.call css }
  let(:user_note) { "/* #{described_class::USER_CONTENT} */\n" }

  def media_query_wrap css
    "#{user_note}#{described_class::MEDIA_QUERY_CSS} {\n#{css}\n}"
  end

  context '#strip_comments' do
    let(:css) { '/* test */ a { color: red }' }
    it do
      is_expected.to eq(
        imports: {},
        compiled_css: media_query_wrap('a { color: red }')
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
        suffixes.each do |suffix_value|
          describe "suffix `#{suffix_value}`" do
            let(:quote) { quote_value }
            let(:suffix) { suffix_value }

            it do
              is_expected.to eq(
                imports: {},
                compiled_css: media_query_wrap(
                  "body { background: url(#{quote}#{camo_url}#{quote})#{suffix} }"
                )
              )
            end
          end
        end
      end
    end

    context 'evil url' do
      let(:image_url) { "#{evil_protocol}some-image.domain" }
      let(:quote) { quotes.sample }
      let(:suffix) { suffixes.sample }

      [
        'http:',
        'https:',
        ''
      ].each do |protocol_part_value|
        broken_protocol_part = "#{protocol_part_value}/"
        describe protocol_part_value do
          [
            1.upto(9).map { |i| "#{protocol_part_value}/#{'\\' * i}/" }.sample,
            "#{protocol_part_value}\\r//",
            "#{protocol_part_value}/\\r/",
            "#{protocol_part_value}//<",
            broken_protocol_part,
            "#{protocol_part_value}/\\\r\n/"
          ].each do |evil_protocol_value|
            next if protocol_part_value == '' && evil_protocol_value == broken_protocol_part

            describe evil_protocol_value do
              let(:protocol_part) { protocol_part_value }
              let(:evil_protocol) { evil_protocol_value }
              let(:camo_url) do
                if evil_protocol_value == broken_protocol_part
                  UrlGenerator.instance.camo_url "#{evil_protocol}some-image.domain"
                else
                  UrlGenerator.instance.camo_url "#{protocol_part}//some-image.domain"
                end
              end

              it do
                is_expected.to eq(
                  imports: {},
                  compiled_css: media_query_wrap(
                    "body { background: url(#{quote}#{camo_url}#{quote})#{suffix} }"
                  )
                )
              end
            end
          end
        end
      end
    end

    context 'non urls are not sanitized' do
      let(:css) { 'body { color:RGBA(var(--marker-color)/var(--marker-background-opacity)) }' }
      it do
        is_expected.to eq(
          imports: {},
          compiled_css: media_query_wrap(css)
        )
      end
    end
  end

  context '#sanitize' do
    let(:css) { 'a { color: red }; javascript:blablalba;;' }
    it do
      is_expected.to eq(
        imports: {},
        compiled_css: media_query_wrap('a { color: red }; :blablalba;')
      )
    end
  end

  describe '#media_query' do
    context 'with styles' do
      context 'with media' do
        let(:css) { user_note + '@media only screen and (min-width: 100px) { a { color: red } }' }
        it do
          is_expected.to eq(
            imports: {},
            compiled_css: css
          )
        end
      end

      context 'without media' do
        let(:css) { 'a { color: red }' }
        it do
          is_expected.to eq(
            imports: {},
            compiled_css: media_query_wrap('a { color: red }')
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
              imports: {
                'https://thiaya.github.io/1/shi.Modern.css' => 115,
                'https://thiaya.github.io/2/shi.Modern.css' => 41
              },
              compiled_css: "/* https://thiaya.github.io/1/shi.Modern.css */\n" \
                "a { background: url('#{camo_url}'); }" \
                "\n\n" \
                "/* https://thiaya.github.io/2/shi.Modern.css */\n" \
                'a { color: blue; }' \
                "\n\n" +
                media_query_wrap('a { color: red; }')
            )
          end
        end
      end
    end

    context 'without styles' do
      let(:css) { '' }
      it do
        is_expected.to eq(
          imports: {},
          compiled_css: ''
        )
      end
    end
  end
end
