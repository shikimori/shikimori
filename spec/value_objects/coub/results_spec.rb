describe Coub::Results do
  let(:coub_results) { Coub::Results.new coubs: coubs, iterator: iterator }
  let(:coubs) { [] }
  let(:iterator) { 'zxc' }

  describe '#checksum' do
    it { expect(coub_results.checksum).to eq 'b3e2686333cb0903809f8faf5ea7a3678f1e6fcc6bec8e30d541d42678e5b6b9' }
  end
end
