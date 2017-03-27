describe YandexMetrika, vcr: { cassette_name: 'yandex_metric' } do
  let(:service) { YandexMetrika.new }

  include_context :timecop, '2015-01-03'

  describe 'traffic_for_months' do
    subject(:traffic) { service.traffic_for_months 18 }

    it 'has at least 500 items' do
      expect(subject.size).to be >= 500
    end

    describe 'entry' do
      subject { traffic.first }
      it { should be_kind_of TrafficEntry }
    end
  end
end
