describe Url do
  let(:string) { 'lenta.ru' }
  let(:url) { Url.new string }

  describe '#without_protocol' do
    subject { url.without_protocol.to_s }

    context 'has_http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq '//test.org' }
    end

    context 'no_http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq '//test.org' }
    end
  end

  describe '#without_port' do
    subject { url.without_port.to_s }

    context 'with path' do
      let(:string) { 'http://test.org:3000/test' }
      it { is_expected.to eq 'http://test.org/test' }
    end

    context 'without path' do
      let(:string) { 'http://test.org:3000' }
      it { is_expected.to eq 'http://test.org' }
    end

    context 'with params' do
      let(:string) { 'http://test.org:3000?zxc=123' }
      it { is_expected.to eq 'http://test.org?zxc=123' }
    end
  end

  describe '#with_http' do
    subject { url.with_http.to_s }

    context 'has http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'http://test.org' }
    end

    context 'no protocol' do
      let(:string) { '//test.org' }
      it { is_expected.to eq 'http://test.org' }
    end

    context 'no http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq 'http://test.org' }
    end
  end

  describe '#without_http' do
    subject { url.without_http.to_s }

    context 'has http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'test.org' }
    end

    context 'no protocol' do
      let(:string) { '//test.org' }
      it { is_expected.to eq 'test.org' }
    end

    context 'no http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq 'test.org' }
    end
  end

  describe '#without_path' do
    subject { url.without_path.to_s }

    context 'protocol' do
      let(:string) { 'http://test.org/test' }
      it { is_expected.to eq 'http://test.org' }
    end

    context 'no protocol' do
      let(:string) { '//test.org/test' }
      it { is_expected.to eq '//test.org' }
    end

    context '/' do
      let(:string) { 'https://test.org/' }
      it { is_expected.to eq 'https://test.org' }
    end

    context 'no http' do
      let(:string) { 'test.org/test' }
      it { is_expected.to eq 'test.org' }
    end
  end

  describe '#domain' do
    subject { url.domain.to_s }

    context 'with port' do
      let(:string) { 'http://test.org:3000/test' }
      it { is_expected.to eq 'test.org' }
    end

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

  describe '#protocol' do
    subject { url.protocol.to_s }

    context 'http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'http' }
    end

    context 'https' do
      let(:string) { 'https://test.org' }
      it { is_expected.to eq 'https' }
    end

    context 'generic' do
      let(:string) { '//test.org' }
      it { is_expected.to eq '' }
    end

    context 'no protocol' do
      let(:string) { '' }
      it { is_expected.to eq '' }
    end
  end

  describe '#add_www' do
    subject { url.add_www.to_s }

    context 'with www' do
      context 'with protocol' do
        let(:string) { 'http://www.test.org/test' }
        it { is_expected.to eq 'http://www.test.org/test' }
      end

      context 'without protocol' do
        let(:string) { 'www.test.org/test' }
        it { is_expected.to eq 'www.test.org/test' }
      end
    end

    context 'without www' do
      let(:string) { 'http://test.org/test' }
      it { is_expected.to eq 'http://www.test.org/test' }
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

  describe '#cut_subdomain' do
    subject { url.cut_subdomain.to_s }

    context 'with www' do
      context 'with protocol' do
        let(:string) do
          %w[
            http://www.test.org/test
            http://xxx.test.org/test
            http://zxc-123-vxc_sd.test.org/test
          ].sample
        end
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

  describe '#cut_slash' do
    subject { url.cut_slash.to_s }

    let(:string) do
      %w[
        http://test.org/test/
        http://test.org/test
      ].sample
    end
    it { is_expected.to eq 'http://test.org/test' }
  end

  describe '#params' do
    subject { url.params(hash) }
    let(:hash) do
      { 'p1' => 'p1', 'p2' => 'p2' }
    end

    context 'link has params' do
      let(:string) { 'http://test.org/test?p0=p0' }
      it { is_expected.to eq 'http://test.org/test?p0=p0&p1=p1&p2=p2' }
    end

    context 'link without params' do
      let(:string) { 'http://test.org/test' }
      it { is_expected.to eq 'http://test.org/test?p1=p1&p2=p2' }
    end

    context 'link with the same params' do
      let(:string) { 'http://test.org/test?p1=p1' }
      it { is_expected.to eq 'http://test.org/test?p1=p1&p2=p2' }
    end

    context 'passed params overwrites query string' do
      let(:string) { 'http://test.org/test?p1=pppp1' }
      it { is_expected.to eq 'http://test.org/test?p1=p1&p2=p2' }
    end
  end

  describe '#param' do
    subject { url.param(param_name) }
    let(:string) { 'http://test.org/test?p1=p1&p2=p2' }

    context 'param exists' do
      let(:param_name) { :p1 }
      it { is_expected.to eq 'p1' }
    end

    context "param doesn't exist" do
      let(:param_name) { :p3 }
      it { is_expected.to be_nil }
    end

    context 'no params' do
      let(:string) { 'http://test.org/test' }
      let(:param_name) { :p3 }

      it { is_expected.to be_nil }
    end
  end
end
