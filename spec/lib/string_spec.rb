describe String do
  subject { 'тЕст' }

  its(:capitalize) { should eq 'Тест' }
  its(:downcase) { should eq 'тест' }

  describe '#with_http' do
    subject { string.with_http }

    context 'has_http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'http://test.org' }
    end

    context 'no_http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq 'http://test.org' }
    end
  end

  describe '#without_http' do
    subject { string.without_http }

    context 'has_http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'test.org' }
    end

    context 'no_http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq 'test.org' }
    end
  end

  describe '#extract_domain' do
    subject { url.extract_domain }

    context 'with_www' do
      let(:url) { "http://www.test.org/test" }
      it { is_expected.to eq 'www.test.org' }
    end

    context 'without_www' do
      let(:url) { "http://test.org/test" }
      it { is_expected.to eq 'test.org' }
    end
  end
end
