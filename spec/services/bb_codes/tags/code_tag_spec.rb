describe BbCodes::Tags::CodeTag do
  let(:tag) { described_class.new text }
  let(:other_tag) { BbCodes::Tags::BTag.instance }

  let(:placeholder_1) { described_class::CODE_PLACEHOLDER }
  let(:placeholder_2) { described_class::CODE_PLACEHOLDER_2 }

  describe '#preprocess' do
    subject { tag.preprocess }

    context 'code block' do
      context 'sample' do
        let(:text) { '[code]zxc[/code]' }
        it { is_expected.to eq placeholder_1 }
      end

      context 'sample' do
        let(:text) { 'q[code]zxc[/code]w' }
        it { is_expected.to eq "q#{placeholder_1}w" }
      end

      context 'sample' do
        let(:text) { 'q[code]zxc[/code]w[code]qwe[/code]1' }
        it { is_expected.to eq "q#{placeholder_1}w#{placeholder_1}1" }
      end
    end

    context 'code inline' do
      context 'sample' do
        let(:text) { '`zxcz`' }
        it { is_expected.to eq placeholder_2 }
      end

      context 'sample' do
        let(:text) { 'q`zxc`w' }
        it { is_expected.to eq "q#{placeholder_2}w" }
      end

      context 'sample' do
        let(:text) { 'q`zxc`w`qwe`1' }
        it { is_expected.to eq "q#{placeholder_2}w#{placeholder_2}1" }
      end

      context 'sample' do
        let(:text) { "`q\nw`" }
        it { is_expected.to eq text }
      end

      context 'sample' do
        let(:text) { '``zx`cz``' }
        it { is_expected.to eq placeholder_2 }
      end

      context 'sample' do
        let(:text) { '```zx`cz``' }
        it { is_expected.to eq "`#{placeholder_2}" }
      end

      context 'sample' do
        let(:text) { '``zx`cz```' }
        it { is_expected.to eq "#{placeholder_2}`" }
      end
    end
  end

  describe '#preprocess, #postprocess' do
    subject { tag.postprocess other_tag.format(tag.preprocess) }

    context 'code block' do
      context 'without language' do
        let(:text) { "[code]#{content}[/code]" }

        context 'inline' do
          let(:content) { '[b]test[/b]' }
          it { is_expected.to eq "<code class='b-code_inline'>#{content}</code>" }
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

    context 'code inline' do
      let(:text) { "`#{content}`" }

      context 'one line' do
        let(:content) { 'qe' }
        it { is_expected.to eq "<code class='b-code_inline'>#{content}</code>" }
      end

      context 'multiline' do
        let(:content) { "q\ne" }
        it { is_expected.to eq text }
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
