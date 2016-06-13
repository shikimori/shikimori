describe Url do
  let(:string) { 'lenta.ru' }
  let(:url) { Url.new string }

  describe '#with_http' do
    subject { url.with_http.to_s }

    context 'has_http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'http://test.org' }
    end

    context 'no_http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq 'http://test.org' }
    end
  end

  describe 'without_http' do
    subject { url.without_http.to_s }

    context 'has_http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'test.org' }
    end

    context 'no_http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq 'test.org' }
    end
  end

  describe 'protocolless' do
    subject { url.protocolless.to_s }

    context 'has_http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq '//test.org' }
    end

    context 'no_http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq '//test.org' }
    end
  end

  describe '#extract_domain' do
    subject { url.domain.to_s }

    context 'with www' do
      let(:string) { 'http://www.test.org/test' }
      it { is_expected.to eq 'www.test.org' }
    end

    context 'without www' do
      let(:string) { 'http://test.org/test' }
      it { is_expected.to eq 'test.org' }
    end

    context 'get params' do
      let(:string) { 'http://test.org?zz=1' }
      it { is_expected.to eq 'test.org' }
    end
  end

  describe '#cut_www' do
    subject { url.cut_www.to_s }

    context 'with www' do
      context 'with protocol' do
        let(:string) { 'http://www.test.org/test' }
        it { is_expected.to eq 'http://test.org/test' }
      end

      context 'without protocol' do
        let(:string) { 'www.test.org/test' }
        it { is_expected.to eq 'test.org/test' }
      end
    end

    context 'without www' do
      let(:string) { 'http://test.org/test' }
      it { is_expected.to eq 'http://test.org/test' }
    end
  end
end
