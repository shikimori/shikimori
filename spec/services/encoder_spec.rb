describe Encoder do
  let(:service) { described_class.instance }

  describe '#encode' do
    it { expect(service.encode('test')).to eq 'dGVzdA==$$663afaef5b945f4b0609167b023527fc' }
  end

  describe '#decode' do
    subject { service.decode text }

    context 'valid text' do
      let(:text) { 'dGVzdA$$663afaef5b945f4b0609167b023527fc' }
      it { is_expected.to eq 'test' }
    end

    context 'invalid text' do
      let(:text) do
        %w[
          GVzdA==$$663afaef5b945f4b0609167b023527fc
          dGVzdA==$$663afaef5b945f4b0609167b023527f
        ].sample
      end
      it { is_expected.to be_nil }
    end

    context 'utf8 symbols' do
      let(:text) { service.encode 'test ψ-nan' }
      it { is_expected.to eq 'test ψ-nan' }
    end
  end

  # describe '#encrypt' do
  #   it { expect(service.encrypt('test')).to match(/^\w{64}\$\$\w{67}=--\w{40}$/) }
  # end

  # describe '#decrypt' do
  #   subject { service.decrypt text }

  #   context 'valid text' do
  #     let(:text) { service.encrypt 'test' }
  #     it { is_expected.to eq 'test' }
  #   end

  #   context 'invalid text' do
  #     let(:text) { ['zxcz', nil, :zxc].sample }
  #     it { is_expected.to be_nil }
  #   end
  # end
end
