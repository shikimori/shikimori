require 'spec_helper'

describe YandexMetrika, vcr: { use_cassette: 'yandex_metric' } do
  let(:service) { YandexMetrika.new }

  describe :traffic_for_monthes do
    subject(:traffic) { service.traffic_for_monthes 18 }

    it { should have_at_least(500).items }

    describe :entry do
      subject { traffic.first }
      it { should be_kind_of TrafficEntry }
    end
  end
end
