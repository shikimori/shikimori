# frozen_string_literal: true

describe Anidb::Authorization, :vcr do
  let(:service) { Anidb::Authorization.instance }

  describe '#cookie' do
    subject { service.cookie }

    it do
      is_expected.to eq %w(
        adbautopass=vbzjomexrccnxcla;
        adbautouser=naruto2148;
        adbsessuser=naruto2148;
        adbuin=1490295269-RLyR;
      )
    end

    describe 'caching' do
      let(:cookies) { 'zzz' }
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
