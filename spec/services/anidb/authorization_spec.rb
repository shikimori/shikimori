# frozen_string_literal: true

describe Anidb::Authorization do
  let(:service) { Anidb::Authorization.instance }

  describe '#cookie_string', vcr: {
    cassette_name: 'Anidb_Authorization/cookie_string'
  } do
    subject { service.cookie_string }

    it do
      is_expected.to eq(
        'adbuin=1619024303-Arfb; '\
        'adbsess=nCOVLMqnGUAfKtji; '\
        'adbsessuser=naruto1452; '\
        'adbss=911926-nCOVLMqn; '\
        'anidbsettings=%7B%22USEAJAX%22%3A1%7D;'
      )
    end

    describe 'caching' do
      let(:cookies) { ['zzz'] }
      before do
        allow(Rails.cache).to receive :write
        allow(service).to receive(:authorize).and_return cookies
      end
      before { subject }

      it do
        expect(Rails.cache)
          .to have_received(:write)
          .with Anidb::Authorization::CACHE_KEY, cookies, {}
      end
    end
  end

  describe '#refresh' do
    before do
      allow(Rails.cache).to receive :delete
      allow(service).to receive :cookie
    end
    before { service.refresh }

    it do
      expect(Rails.cache)
        .to have_received(:delete)
        .with Anidb::Authorization::CACHE_KEY
      expect(service).to have_received :cookie
    end
  end
end
