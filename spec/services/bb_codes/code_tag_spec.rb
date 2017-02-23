describe BbCodes::CodeTag do
  let(:tag) { BbCodes::CodeTag.new text }
  let(:other_tag) { BbCodes::BTag.instance }

  subject { tag.postprocess other_tag.format(tag.preprocess) }

  context 'without language' do
    let(:text) { '[code][b]test[/b][/code]' }

    it do
      is_expected.to eq(
        <<-HTML.gsub(/\ *\n\ */, '').strip
          <pre class='to-process' data-dynamic='code_highlight'>
            <code class='nohighlight'>
              [b]test[/b]
            </code>
          </pre>
        HTML
      )
    end
  end

  context 'with language' do
    let(:text) { '[code=ruby][b]test[/b][/code]' }

    it do
      is_expected.to eq(
        <<-HTML.gsub(/\ *\n\ */, '').strip
          <pre class='to-process' data-dynamic='code_highlight'>
            <code class='ruby'>
              [b]test[/b]
            </code>
          </pre>
        HTML
      )
    end
  end
end
