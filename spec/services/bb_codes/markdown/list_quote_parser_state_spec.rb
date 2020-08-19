describe BbCodes::Markdown::ListQuoteParserState do
  subject { described_class.new(text).to_html }

  context 'list' do
    context 'single line' do
      let(:text) { ['- a', '+ a', '* a'].sample }
      it { is_expected.to eq "<ul class='b-list'><li>a</li></ul>" }
    end

    context 'sample' do
      let(:text) { '- qwe' }
      it { is_expected.to eq "<ul class='b-list'><li>qwe</li></ul>" }
    end

    context 'sample' do
      let(:text) { "- qwe\n" }
      it { is_expected.to eq "<ul class='b-list'><li>qwe</li></ul>" }
    end

    context 'item content on next line' do
      let(:text) { "- a\n  b" }
      it { is_expected.to eq "<ul class='b-list'><li>a\nb</li></ul>" }
    end

    context 'content after' do
      let(:text) { "- a\nb" }
      it { is_expected.to eq "<ul class='b-list'><li>a</li></ul>b" }
    end

    context 'multiline' do
      let(:text) { "- a\n- b" }
      it { is_expected.to eq "<ul class='b-list'><li>a</li><li>b</li></ul>" }
    end

    context 'moves through inner tags', :focus do
      let(:text) { "- #{content}\n- c" }
      let(:content) { "z [spoiler=x]x\nx[/spoiler]" }

      it do
        is_expected.to eq(
          "<ul class='b-list'><li>#{content}</li><li>c</li></ul>"
        )
      end
    end
  end

  context 'blockquote' do
    context 'sample' do
      let(:text) { '> qwe' }
      it { is_expected.to eq "<blockquote class='b-quote-v2'>qwe</blockquote>" }
    end

    context 'sample' do
      let(:text) { '&gt; qwe' }
      it { is_expected.to eq "<blockquote class='b-quote-v2'>qwe</blockquote>" }
    end

    context 'multiline' do
      let(:text) { "> a\n> b\n> c" }
      it do
        is_expected.to eq(
          "<blockquote class='b-quote-v2'>a\nb\nc</blockquote>"
        )
      end
    end

    context 'nested blockquote' do
      let(:text) { '> > test' }
      it do
        is_expected.to eq(
          "<blockquote class='b-quote-v2'>" \
            "<blockquote class='b-quote-v2'>test</blockquote>" \
            '</blockquote>'
        )
      end
    end

    context 'nested blockquote multiline' do
      let(:text) { "> > test\n> b" }
      it do
        is_expected.to eq(
          "<blockquote class='b-quote-v2'>" \
            "<blockquote class='b-quote-v2'>test</blockquote>" \
            'b</blockquote>'
        )
      end
    end
  end

  context 'list + blockquote' do
    context 'sample' do
      let(:text) { '+ > test' }
      it do
        is_expected.to eq(
          "<ul class='b-list'><li>" \
            "<blockquote class='b-quote-v2'>test</blockquote>" \
            '</li></ul>'
        )
      end
    end

    context 'sample' do
      let(:text) { "+ > test\n  > 123" }
      it do
        is_expected.to eq(
          "<ul class='b-list'><li>" \
            "<blockquote class='b-quote-v2'>test\n123</blockquote>" \
            '</li></ul>'
        )
      end
    end

    context 'sample' do
      let(:text) { "> - test\n>   123" }
      it do
        is_expected.to eq(
          "<blockquote class='b-quote-v2'>" \
            "<ul class='b-list'><li>test\n123</li></ul>" \
            '</blockquote>'
        )
      end
    end

    context 'sample' do
      let(:text) { "- > 123\n> - 456\n>   789" }

      it do
        is_expected.to eq(
          "<ul class='b-list'><li>" \
            "<blockquote class='b-quote-v2'>" \
              '123' \
            '</blockquote></li></ul>' \
            "<blockquote class='b-quote-v2'>" \
              "<ul class='b-list'><li>456\n789</li></ul>" \
            '</blockquote>'
        )
      end
    end
  end
end
