describe BbCodes::CleanupHtml do
  subject { described_class.call text }

  context 'broken html' do
    let(:text) { '<div><span>a</div></span>' }
    it { is_expected.to eq '<div><span>a</span></div>' }
    it { is_expected.to be_html_safe }
  end

  context 'broken html #2' do
    let(:text) { '<div>a' }
    it { is_expected.to eq '<div>a</div>' }
  end

  # context 'multiple symbols' do
  #   let(:text) { '((((((((((((()))))))))))!!!!!!!!!!!!????????????' }
  #   it { is_expected.to eq '()!?' }
  # end

  context 'multiple smileys' do
    let(:smiley) { '<img src="/images/smileys/:).gif" alt=":)" title=":)" class="smiley">' }

    context 'lte 3 smileys' do
      let(:text) { "#{smiley}#{smiley}#{smiley}" }
      it { is_expected.to eq text }
    end

    context 'gt 3 smileys' do
      let(:text) { "#{smiley}#{smiley}#{smiley}#{smiley}" }
      it { is_expected.to eq smiley }
    end
  end
end
