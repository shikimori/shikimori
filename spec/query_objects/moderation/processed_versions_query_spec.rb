describe Moderation::ProcessedVersionsQuery do
  let(:query) { Moderation::ProcessedVersionsQuery.new 'content', created_on }
  let(:created_on) { nil }

  before { Timecop.freeze '2016-03-18 15:00:00' }
  after { Timecop.return }

  let(:user) { create :user }
  let!(:version_1) { create :version, state: 'taken', updated_at: 1.minute.ago, created_at: 28.hours.ago }
  let!(:version_2) { create :version, state: 'pending', updated_at: 2.minutes.ago, created_at: 2.hours.ago }
  let!(:version_3) { create :version, state: 'accepted', updated_at: 3.minutes.ago, created_at: 29.hours.ago }
  let!(:version_4) { create :version, state: 'deleted', updated_at: 4.minutes.ago, created_at: 40.hours.ago }

  describe '#fetch' do
    subject { query.fetch page, limit }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { is_expected.to eq [version_1, version_3, version_4] }

      context 'with created_on' do
        let(:created_on) { 1.day.ago.to_date.to_s }
        it { is_expected.to eq [version_1, version_3] }
      end
    end

    context 'second_page' do
      let(:page) { 2 }
      it { is_expected.to eq [version_4] }
    end
  end

  describe '#postload' do
    subject { query.postload page, limit }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { is_expected.to eq [[version_1, version_3], true] }
    end

    context 'second_page' do
      let(:page) { 2 }
      it { is_expected.to eq [[version_4], false] }
    end
  end
end
