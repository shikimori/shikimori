describe String do
  subject { 'тЕст' }

  its(:capitalize) { should eq 'Тест' }
  its(:upcase) { should eq 'ТЕСТ' }
  its(:downcase) { should eq 'тест' }

  describe '#first_downcase' do
    let(:string) { 'Реклама ВКонтакте' }
    it { expect(string.first_downcase).to eq 'реклама ВКонтакте' }
  end

  describe '#first_upcase' do
    let(:string) { 'реклама ВКонтакте' }
    it { expect(string.first_upcase).to eq 'Реклама ВКонтакте' }
  end

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

    context 'no_protocol' do
      let(:string) { '//youtube.ru/foo' }
      it { is_expected.to eq 'http://youtube.ru/foo' }
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
