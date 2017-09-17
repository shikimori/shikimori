describe Network::ExtractMetaRedirect do
  let(:service) { Network::ExtractMetaRedirect.new html }
  subject { service.call }

  let(:html) do
    <<-HTML.squish
      <html>
        <head>
          <META http-equiv="#{http_equiv}" content="#{content}">
        </head>
      </html>
    HTML
  end
  let(:http_equiv) { 'refresh' }
  let(:content) { "0; URL='#{url}'" }
  let(:url) { 'http://ya.ru' }

  describe 'without redirect' do
    context 'no meta' do
      let(:html) { '<html></html>' }
      it { is_expected.to be_nil }
    end

    context 'no http-equiv' do
      let(:http_equiv) { '' }
      it { is_expected.to be_nil }
    end

    context 'no content' do
      let(:content) { '' }
      it { is_expected.to be_nil }
    end

    context 'no url' do
      let(:url) { '' }
      it { is_expected.to be_nil }
    end
  end

  describe 'with redirect' do
    context 'rfc' do
      it { is_expected.to eq url }
    end

    context 'without quotes' do
      let(:content) { "0; url=#{url}" }
      it { is_expected.to eq url }

      context 'with space' do
        let(:content) { "0; url= #{url}" }
        it { is_expected.to eq url }
      end
    end

    context 'without first part' do
      let(:content) { "url=#{url}" }

      it { is_expected.to eq url }

      context 'without URL=' do
        let(:content) { "'#{url}'" }
        it { is_expected.to eq url }
      end
    end

    context 'without URL=' do
      let(:content) { "0; '#{url}'" }

      it { is_expected.to eq url }

      context 'without quotes' do
        let(:content) { "0; #{url}" }
        it { is_expected.to eq url }
      end
    end
  end
end
