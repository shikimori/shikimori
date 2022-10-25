describe UserHistoryQuery do
  let(:query) { UserHistoryQuery.new user }

  let(:anime) { create :anime }
  let(:page) { 1 }
  let(:limit) { 1 }

  subject { query.postload page, limit }

  describe '#postload' do
    let!(:history) { create :user_history, user: user, anime: anime }

    context 'one page' do
      its(:first) { should eq(today: [history]) }
      its(:second) { should be false }
    end

    context 'two pages' do
      let!(:history_2) do
        create :user_history, user: user, anime: anime, updated_at: 2.days.ago
      end

      context 'first page' do
        its(:first) { should eq(today: [history]) }
        its(:second) { should be true }
      end

      context 'second page' do
        let(:page) { 2 }
        its(:first) { should eq(during_week: [history_2]) }
        its(:second) { should be false }
      end
    end
  end

  describe 'date_interval' do
    it { expect(query.date_interval Time.zone.now).to eq :today }
    it { expect(query.date_interval 1.day.ago).to eq :yesterday }
    it { expect(query.date_interval 5.days.ago).to eq :during_week }
    it { expect(query.date_interval 8.days.ago).to eq :week }
    it { expect(query.date_interval 15.days.ago).to eq :two_weeks }
    it { expect(query.date_interval 22.days.ago).to eq :three_weeks }
    it { expect(query.date_interval 32.days.ago).to eq :month }
    it { expect(query.date_interval 63.days.ago).to eq :two_months }
    it { expect(query.date_interval 94.days.ago).to eq :three_months }
    it { expect(query.date_interval 125.days.ago).to eq :four_months }
    it { expect(query.date_interval 156.days.ago).to eq :five_months }
    it { expect(query.date_interval 187.days.ago).to eq :half_year }
    it { expect(query.date_interval 367.days.ago).to eq :year }
    it { expect(query.date_interval 735.days.ago).to eq :two_years }
    it { expect(query.date_interval 1102.days.ago).to eq :many_years }
  end
end
