describe Encoder do
  let(:service) { described_class.instance }

  describe '#encrypt' do
    it { expect(service.encrypt('test')).to eq 'dGVzdA$$663afaef5b945f4b0609167b023527fc' }
  end

  describe '#decrypt' do
    subject { service.decrypt text }

    context 'valid text' do
      let(:text) { 'dGVzdA$$663afaef5b945f4b0609167b023527fc' }
      it { is_expected.to eq 'test' }
    end

    context 'invalid text' do
      let(:text) do
        %w[
          dGVzdA1$$663afaef5b945f4b0609167b023527fc
          dGVzdA$$663afaef5b945f4b0609167b023527fc1
        ].sample
      end
      it { is_expected.to be_nil }
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
