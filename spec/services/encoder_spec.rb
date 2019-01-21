describe Encoder do
  let(:service) { described_class.instance }

  # describe '#encode' do
  #   it { expect(service.encode('test')).to eq 'dGVzdA==$$663afaef5b945f4b0609167b023527fc' }
  # end

  # describe '#decode' do
  #   subject { service.decode text }

  #   context 'valid text' do
  #     let(:text) { 'dGVzdA$$663afaef5b945f4b0609167b023527fc' }
  #     it { is_expected.to eq 'test' }
  #   end

  #   context 'invalid text' do
  #     let(:text) do
  #       %w[
  #         GVzdA==$$663afaef5b945f4b0609167b023527fc
  #         dGVzdA==$$663afaef5b945f4b0609167b023527f
  #       ].sample
  #     end
  #     it { is_expected.to be_nil }
  #   end

  #   context 'utf8 symbols' do
  #     let(:text) { service.encode 'test ψ-nan' }
  #     it { is_expected.to eq 'test ψ-nan' }
  #   end
  # end

  describe '#checksum' do
    it do
      expect(service.checksum('test')).to eq(
        '40652654a739ea1bf250a76fd9c05f15a281fea48799a520cf46c8b60eb96ac5'
      )
    end
  end

  describe '#valid?' do
    let(:string) { 'test' }
    subject { service.valid? text: string, hash: checksum }

    context 'valid' do
      let(:checksum) { service.checksum string }
      it { is_expected.to eq true }
    end

    context 'invalid' do
      let(:checksum) { 'zxc' }
      it { is_expected.to eq false }
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
