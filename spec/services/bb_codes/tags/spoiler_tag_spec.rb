describe BbCodes::Tags::SpoilerTag do
  subject { described_class.instance.format text }

  let(:text) do
    eqls_label = label.present? ? "=#{label}" : ''
    "#{prefix}[#{tag}#{eqls_label}#{fullwidth}]#{content}[/#{tag}]#{suffix}"
  end
  let(:tag) { 'spoiler' }
  let(:label) { 'bl<b>a</b>bla' }
  let(:prefix) { '' }
  let(:suffix) { ['\n', ' ', 'zxc'].sample }
  let(:fullwidth) { '' }
  let(:content) { 'test' }

  context 'old style' do
    let(:prefix) { 'qwe ' }
    let(:content) { ['test', "te\nst"].sample }

    it do
      is_expected.to eq(
        prefix +
          "<div class='b-spoiler unprocessed'>" \
            "<label>#{label}</label>" \
            "<div class='content'>" \
              "<div class='before'></div>" \
              "<div class='inner'>#{content}</div>" \
              "<div class='after'></div>" \
            '</div>' \
          '</div>' + suffix
      )
    end

    context 'strip label' do
      let(:label) { ' a ' }
      it do
        is_expected.to eq(
          prefix +
            "<div class='b-spoiler unprocessed'>" \
              '<label>a</label>' \
              "<div class='content'>" \
                "<div class='before'></div>" \
                "<div class='inner'>#{content}</div>" \
                "<div class='after'></div>" \
              '</div>' \
            '</div>' + suffix
        )
      end
    end

    context 'spoiler_v1' do
      let(:prefix) { ["\n", '<div>', '</div>'].sample }
      let(:tag) { 'spoiler_v1' }

      it do
        is_expected.to eq(
          prefix +
            "<div class='b-spoiler unprocessed'>" \
              "<label>#{label}</label>" \
              "<div class='content'>" \
                "<div class='before'></div>" \
                "<div class='inner'>#{content}</div>" \
                "<div class='after'></div>" \
              '</div>' \
            '</div>' + suffix
        )
      end
    end
  end

  context 'block' do
    let(:prefix) { '' }
    let(:label) { 'blabla' }
    let(:suffix) { '' }

    it do
      is_expected.to eq(
        "<div class='b-spoiler_block to-process' data-dynamic='spoiler_block'>" \
          "<span tabindex='0'>#{label}</span>" \
          "<div>#{content}</div>" \
        '</div>'
      )
    end

    context 'fullwidth' do
      let(:fullwidth) { ' fullwidth' }

      context 'with label' do
        it do
          is_expected.to eq(
            "<div class='b-spoiler_block to-process is-fullwidth' data-dynamic='spoiler_block'>" \
              "<span tabindex='0'>#{label}</span>" \
              "<div>#{content}</div>" \
            '</div>'
          )
        end
      end

      context 'w/o label' do
        let(:label) { '' }
        it do
          is_expected.to eq(
            "<div class='b-spoiler_block to-process is-fullwidth' data-dynamic='spoiler_block'>" \
              "<span tabindex='0'>спойлер</span>" \
              "<div>#{content}</div>" \
            '</div>'
          )
        end
      end
    end

    context 'no \n suffix' do
      let(:suffix) { [' ', 'zxc'].sample }

      it do
        is_expected.to eq(
          prefix +
            "<div class='b-spoiler_block to-process' data-dynamic='spoiler_block'>" \
              "<span tabindex='0'>#{label}</span>" \
              "<div>#{content}</div>" \
            '</div>' + suffix
        )
      end
    end

    context '\n inside' do
      let(:content) { "qwerty\n" }
      it do
        is_expected.to eq(
          prefix +
            "<div class='b-spoiler_block to-process' data-dynamic='spoiler_block'>" \
              "<span tabindex='0'>#{label}</span>" \
              '<div>qwerty</div>' \
            '</div>' + suffix
        )
      end
    end

    context '\n suffix' do
      let(:suffix) { "\n" }

      it do
        is_expected.to eq(
          prefix +
            "<div class='b-spoiler_block to-process' data-dynamic='spoiler_block'>" \
              "<span tabindex='0'>#{label}</span>" \
              "<div>#{content}</div>" \
            '</div>'
        )
      end
    end

    context 'label with markup' do
      let(:label) { 'bl<b>a</b>bla' }
      it { is_expected.to_not include 'b-spoiler_block' }

      context 'tag is spoiler_block' do
        let(:tag) { 'spoiler_block' }
        it { is_expected.to include 'b-spoiler_block' }
      end
    end
  end

  context 'inline' do
    let(:label) { described_class::INLINE_LABELS.sample }
    let(:prefix) { 'qwe ' }

    it do
      is_expected.to eq(
        prefix +
          "<span class='b-spoiler_inline to-process' data-dynamic='spoiler_inline' tabindex='0'>" \
            "<span>#{content}</span>" \
          '</span>' + suffix
      )
    end

    context 'content size' do
      context 'too large' do
        let(:content) { 'a' * (described_class::MAX_DEFAULT_SPOILER_INLINE_SIZE + 1) }
        it { is_expected.to_not include 'b-spoiler_inline' }
      end

      context 'not too large' do
        let(:content) { 'a' * described_class::MAX_DEFAULT_SPOILER_INLINE_SIZE }
        it { is_expected.to include 'b-spoiler_inline' }
      end
    end
  end

  context '[spoiler]' do
    let(:text) { "[spoiler]te\nst[/spoiler]" }
    it { is_expected.to_not include '[spoiler' }
  end

  context 'nested [spoiler]' do
    let(:text) { '[spoiler=test] [spoiler=1]test[/spoiler][/spoiler]' }
    it { is_expected.to_not include '[spoiler' }
  end
end
