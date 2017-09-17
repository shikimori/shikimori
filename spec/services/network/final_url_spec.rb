describe Network::FinalUrl, :vcr do
  subject(:final_url) { Network::FinalUrl.call url }

  describe '#final_url' do
    context 'no redirects' do
      let(:url) { 'http://www.warandpeace.ru' }
      it { expect(final_url).to eq url }
    end

    context 'redirects' do
      let(:url) { 'http://warandpeace.ru' }
      it { expect(final_url).to eq 'http://www.warandpeace.ru/' }
    end

    context 'invalid uri' do
      let(:url) { 'fdgdfg dfgfdg' }
      it { expect(final_url).to be_nil }
    end
  end
end
