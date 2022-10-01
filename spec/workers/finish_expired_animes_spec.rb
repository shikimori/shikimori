describe FinishExpiredAnimes do
  let(:job) { described_class.new }

  include_context :timecop, '2015-06-18'

  describe '#perform' do
    let(:interval) { described_class::EXPIRE_INTERVAL.ago }

    let!(:anons) { create :anime, :anons, aired_on: interval + 1.day }
    let!(:expired_anons) { create :anime, :anons, aired_on: interval - 1.day }

    let!(:ongoing) { create :anime, :ongoing, released_on: interval + 1.day }
    let!(:expired_ongoing) { create :anime, :ongoing, released_on: interval - 1.day }

    before { job.perform }

    it do
      expect(anons.reload).to be_anons
      expect(expired_anons.reload).to be_ongoing

      expect(ongoing.reload).to be_ongoing
      expect(expired_ongoing.reload).to be_released
    end
  end
end
