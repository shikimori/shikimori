describe Encryptor do
  let(:service) { described_class.instance }

  describe '#encrypt' do
    it { expect(service.encrypt('test')).to match(/^\w{64}\$\$\w{67}=--\w{40}$/) }
  end

  describe '#decrypt' do
    it { expect(service.decrypt(service.encrypt('test'))).to eq 'test' }
  end
end
