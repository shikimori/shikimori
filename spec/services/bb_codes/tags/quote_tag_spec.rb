describe BbCodes::Tags::QuoteTag do
  subject { described_class.instance.format text }

  context 'simple quote' do
    let(:text) { '[quote]test[/quote]' }
    it do
      is_expected.to eq(
        "<div class='b-quote'><div class='quote-content'>test</div></div>"
      )
    end

    context 'new lines' do
      let(:text) do
        [
          "[quote]\ntest[/quote]",
          "[quote]test\n[/quote]",
          "[quote]test[/quote]\n",
          "[quote]\ntest\n[/quote]\n"
        ].sample
      end
      it do
        is_expected.to eq(
          "<div class='b-quote'><div class='quote-content'>test</div></div>"
        )
      end
    end

    context 'with text' do
      let(:text) { '[quote=zz]test[/quote]' }
      it do
        is_expected.to eq(
          <<~HTML.squish
            <div class='b-quote'><div
              class='quoteable'>[user]zz[/user]</div><div
              class='quote-content'>test</div></div>
          HTML
        )
      end
    end
  end

  context 'topic quote' do
    let(:text) { '[quote=t1;2;3]test[/quote]' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          <div class='b-quote'><div
            class='quoteable'>[topic=1 quote]3[/topic]</div><div
            class='quote-content'>test</div></div>
        HTML
      )
    end
  end

  context 'message quote' do
    let(:text) { '[quote=m1;2;3]test[/quote]' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          <div class='b-quote'><div
            class='quoteable'>[message=1 quote]3[/message]</div><div
            class='quote-content'>test</div></div>
        HTML
      )
    end
  end

  context 'comment quote' do
    let(:text) { '[quote=c1;2;3]test[/quote]' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          <div class='b-quote'><div
            class='quoteable'>[comment=1 quote]3[/comment]</div><div
            class='quote-content'>test</div></div>
        HTML
      )
    end
  end

  context 'unbalanced quotes' do
    let(:text) { '[quote][quote]test[/quote]' }
    it { is_expected.to eq text }
  end
end
