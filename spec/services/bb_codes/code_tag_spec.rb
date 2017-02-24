describe BbCodes::CodeTag do
  let(:tag) { BbCodes::CodeTag.new text }
  let(:other_tag) { BbCodes::BTag.instance }


  describe '#preprocess, #postprocess' do
    subject { tag.postprocess other_tag.format(tag.preprocess) }

    context 'without language' do
      let(:text) { "[code]#{content}[/code]" }

      context 'inline' do
        let(:content) { '[b]test[/b]' }
        it { is_expected.to eq "<code>#{content}</code>" }
      end

      context 'block' do
        context 'spaces' do
          let(:content) { ' [b]test[/b]' }

          it do
            is_expected.to eq(
              "<pre class='to-process' data-dynamic='code_highlight'>"\
                "<code class='b-code' data-language=''>" +
                  content.strip +
                '</code>'\
              '</pre>'
            )
          end
        end

        context 'new lines' do
          let(:content) { "[b]te\nst[/b]" }

          it do
            is_expected.to eq(
              "<pre class='to-process' data-dynamic='code_highlight'>"\
                "<code class='b-code' data-language=''>" +
                  content +
                '</code>'\
              '</pre>'
            )
          end
        end

        context 'spaces before first symbol' do
          let(:text) { "[code]\n#{content}[/code]" }
          let(:content) { "  test\n  test" }

          it do
            is_expected.to eq(
              "<pre class='to-process' data-dynamic='code_highlight'>"\
                "<code class='b-code' data-language=''>" +
                  content +
                '</code>'\
              '</pre>'
            )
          end
        end
      end
    end

    context 'with language' do
      let(:text) { "[code=ruby]#{content}[/code]" }
      let(:content) { "[b]  \n  test [/b]" }

      it do
        is_expected.to eq(
          "<pre class='to-process' data-dynamic='code_highlight'>"\
            "<code class='b-code' data-language='ruby'>" +
              content +
            '</code>'\
          '</pre>'
        )
      end
    end
  end

  describe '#preprocess, #restore' do
    subject { tag.restore other_tag.format(tag.preprocess) }

    let(:text) { "[code=ruby]#{content}[/code]" }
    let(:content) { "[b]test[/b]" }

    it { is_expected.to eq text }
  end
end
