describe VideoExtractor::BaseExtractor do
  let(:service) { VideoExtractor::BaseExtractor.new 'test' }

  describe 'hosting' do
    subject { service.hosting }
    it { is_expected.to eq :base }
  end
end
