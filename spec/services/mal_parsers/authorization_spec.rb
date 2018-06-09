describe MalParsers::Authorization, :vcr do
  let(:service) { MalParsers::Authorization.instance }

  describe '#cookie' do
    it do
      expect(service.cookie).to eq %w[
        MALSESSIONID=3dtj55b5vrq5th68tdbkdtjrc2;
        is_logged_in=1;
      ]
    end

    describe 'method calls' do
      let(:cookies) { 'zzz' }
      before do
        allow(Rails.cache).to receive :write
        allow(service).to receive(:authorize).and_return cookies
      end
      subject! { service.cookie }

      it do
        expect(Rails.cache)
          .to have_received(:write)
          .with MalParsers::Authorization::CACHE_KEY, cookies, {}
      end
    end
  end

  describe '#refresh' do
    before do
      allow(Rails.cache).to receive :delete
      allow(service).to receive :cookie
    end
    subject! { service.refresh }

    it do
      expect(Rails.cache)
        .to have_received(:delete)
        .with MalParsers::Authorization::CACHE_KEY
      expect(service).to have_received :cookie
    end
  end
end
