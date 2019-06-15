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
    let(:quote) { ['"', "'", '`', ''].sample }
    let(:css) { "body { background: url(#{quote}#{image_url}#{quote}); };" }

    it do
      is_expected.to eq(
        imports: [],
        compiled_css: <<-CSS.squish
          #{described_class::MEDIA_QUERY_CSS} {
            body {
              background: url(#{quote}#{UrlGenerator.instance.camo_url image_url}#{quote});
            };
          }
        CSS
      )
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

        context 'with multiple imports' do
          let(:css) do
            <<~CSS
              @import url('https://zzz.com');
              @import url('https://xxx.com');
              zxc
            CSS
          end

          it do
            is_expected.to eq(
              imports: ['https://zzz.com', 'https://xxx.com'],
              compiled_css: "#{described_class::MEDIA_QUERY_CSS} { zxc }"
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
