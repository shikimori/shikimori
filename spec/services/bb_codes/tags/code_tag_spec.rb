describe BbCodes::Tags::CodeTag do
  let(:tag) { described_class.new }
  let(:other_tag) { BbCodes::Tags::BTag.instance }

  let(:placeholder_1) { described_class::CODE_PLACEHOLDER_1 }
  let(:placeholder_2) { described_class::CODE_PLACEHOLDER_2 }

  describe '#preprocess' do
    subject { tag.preprocess text }

    context 'code block' do
      context 'sample' do
        let(:text) { '[code]zxc[/code]' }
        it { is_expected.to eq placeholder_1 }
      end

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

      context 'markdown' do
        context 'single line' do
          let(:text) { "```\nzxc\n```" }
          it { is_expected.to eq placeholder_1 }
        end

        context 'multiline' do
          let(:text) { "```\nzxc\n```\nq" }
          it { is_expected.to eq "#{placeholder_1}q" }
        end

        context 'nested' do
          context 'in quote' do
            let(:text) { "> ```\n> zxc\n> ```" }
            it { is_expected.to eq "> #{placeholder_1}" }
          end

          context 'in &gt; quote' do
            let(:text) { "&gt; ```\n&gt; zxc\n&gt; ```" }
            it { is_expected.to eq "&gt; #{placeholder_1}" }
          end

          context 'in list' do
            let(:text) { "- ```\n  zxc\n  ```" }
            it { is_expected.to eq "- #{placeholder_1}" }
          end

          context 'in quote then in list' do
            let(:text) { "> - ```\n>   zxc\n>   ```" }
            it { is_expected.to eq "> - #{placeholder_1}" }
          end

          context 'possibly in middle of list' do
            let(:text) { "  ```\n  zxc\n  ```" }
            it { is_expected.to eq "  #{placeholder_1}" }
          end

          context 'content after' do
            context 'ends with \n' do
              let(:text) { "- ```\n  zxc\n  ```\n" }
              it { is_expected.to eq "- #{placeholder_1}" }
            end

            context 'ends with the same nesting' do
              let(:text) { "- ```\n  zxc\n  ```\n  Z" }
              it { is_expected.to eq "- #{placeholder_1}  Z" }
            end

            context 'ends with the same nesting with spaces' do
              let(:text) { "- ```\n  zxc\n  ```\n    Z" }
              it { is_expected.to eq "- #{placeholder_1}    Z" }
            end

            context 'ends with higher nesting' do
              context 'sample' do
                let(:text) { "- ```\n  zxc\n  ```\n  > Z" }
                it { is_expected.to eq "- #{placeholder_1}  > Z" }
              end

              context 'sample' do
                let(:text) { "> ```\n> zxc\n> ```\n> > Z" }
                it { is_expected.to eq "> #{placeholder_1}> > Z" }
              end
            end

            context 'ends with lower nesting' do
              let(:text) { "- ```\n  zxc\n  ```\nZ" }
              it { is_expected.to eq "- #{placeholder_1}Z" }
            end
          end

          context 'invalid markdown' do
            context 'ends in list' do
              let(:text) { "> - ```\n>   zxc\n> - ```" }
              it { is_expected.to eq text }
            end

            context 'ends on another nesting level' do
              let(:text) { "> - ```\n>   zxc\n>     ```" }
              it { is_expected.to eq text }
            end
          end
        end
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

      context 'markdown' do
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
  end

  describe '#preprocess, #postprocess' do
    subject { tag.postprocess other_tag.format(tag.preprocess(text)) }

    context 'bbcode' do
      context 'without language' do
        let(:text) { "[code]#{content}[/code]" }

        context 'inline' do
          let(:content) { '[b]test[/b]' }
          it { is_expected.to eq "<code class='b-code_inline'>#{content}</code>" }

          context 'sample' do
            let(:text) { "[code]#{content}[/code]\ntest" }
            it { is_expected.to eq "<code class='b-code_inline'>#{content}</code><br>test" }
          end
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

    context 'markdown' do
      context 'code_block' do
        let(:content) { ' [b]qe[/b] ' }
        let(:text) { "```\n#{content}\n```" }

        it do
          is_expected.to eq <<-HTML.squish
            <pre class='b-code-v2 to-process' data-dynamic='code_highlight'
              data-language=''><code>#{content}</code></pre>
          HTML
        end

        context 'nested' do
          let(:text) { "> ```\n> #{content}\n> ```" }
          it do
            is_expected.to eq <<-HTML.squish
              > <pre class='b-code-v2 to-process' data-dynamic='code_highlight'
                data-language=''><code>#{content}</code></pre>
            HTML
          end

          context 'ends with \n' do
            let(:text) { "> ```\n> #{content}\n> ```\n" }
            it do
              is_expected.to eq(
                <<-HTML.squish
                  > <pre class='b-code-v2 to-process' data-dynamic='code_highlight'
                    data-language=''><code>#{content}</code></pre>
                HTML
              )
            end
          end
        end
      end

      context 'code_inline' do
        let(:text) { "`#{content}`" }

        context 'one line' do
          let(:content) { ' [b]qe[/b] ' }
          it { is_expected.to eq "<code class='b-code_inline'>#{content}</code>" }
        end

        context 'multiline' do
          let(:content) { "q\ne" }
          it { is_expected.to eq text }
        end
      end
    end

    context 'bbcode + markdown' do
      context 'smaple' do
        let(:text) { '[code]123[/code] `456`' }
        it do
          is_expected.to eq(
            "<code class='b-code_inline'>123</code> " \
              "<code class='b-code_inline'>456</code>"
          )
        end
      end

      context 'smaple' do
        let(:text) { '`123` [code]456[/code]' }
        it do
          is_expected.to eq(
            "<code class='b-code_inline'>123</code> " \
              "<code class='b-code_inline'>456</code>"
          )
        end
      end
    end
  end

  describe '#preprocess, #restore' do
    subject { tag.restore other_tag.format(tag.preprocess(text)) }
    let(:content) { '[b]test[/b]' }

    context 'sample' do
      let(:text) { "[code=ruby]#{content}[/code]" }
      it { is_expected.to eq text }
    end

    context 'sample' do
      let(:text) { "[code=ruby]#{content}[/code]\n" }
      it { is_expected.to eq text }
    end

    context 'sample' do
      let(:text) { "`#{content}`" }
      it { is_expected.to eq text }
    end

    context 'nested markdown' do
      let(:text) { "> ```\n> zxc\n> ```" }
      it { is_expected.to eq text }

      context 'ends with \n and content' do
        let(:text) { "- ```\n  zxc\n  ```\n" }
        it { is_expected.to eq text }
      end

      context 'ends with \n and content' do
        let(:text) { "- ```\n  zxc\n  ```\nafter" }
        it { is_expected.to eq text }
      end
    end
  end
end
