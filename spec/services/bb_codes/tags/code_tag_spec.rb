describe BbCodes::Tags::CodeTag do
  let(:tag) { BbCodes::Tags::CodeTag.new text }
  let(:other_tag) { BbCodes::Tags::BTag.instance }

  describe '#preprocess, #postprocess' do
    subject { tag.postprocess other_tag.format(tag.preprocess) }

    context 'without language' do
      let(:text) { "[code]#{content}[/code]" }

      context 'inline' do
        let(:content) { '[b]test[/b]' }
        it { is_expected.to eq "<code class='b-code-v2-inline'>#{content}</code>" }
      end

      context 'block' do
        context 'spaces' do
          let(:content) { ' [b]test[/b]' }

          it do
            is_expected.to eq <<-HTML.squish
              <pre class='b-code-v2 to-process' data-dynamic='code_highlight'
                data-language=''><code>#{content.strip}</code></pre>
            HTML
          end
        end

        context 'new lines' do
          let(:content) { "[b]te\nst[/b]" }

          it do
            is_expected.to eq(
              "<pre class='b-code-v2 to-process' data-dynamic='code_highlight' "\
                "data-language=''><code>" +
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
              "<pre class='b-code-v2 to-process' data-dynamic='code_highlight' "\
                "data-language=''><code>" +
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
          "<pre class='b-code-v2 to-process' data-dynamic='code_highlight' "\
            "data-language='ruby'><code>" +
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
    let(:content) { '[b]test[/b]' }

    it { is_expected.to eq text }
  end
end
