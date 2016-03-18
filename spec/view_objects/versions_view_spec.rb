describe VersionsView do
  let(:view) { VersionsView.new }

  before { Timecop.freeze '2016-03-18 15:00:00' }
  after { Timecop.return }

  let!(:version_1) { create :version, state: 'taken', created_at: 15.hours.ago, updated_at: 1.minute.ago }
  let!(:version_2) { create :version, state: 'pending', created_at: 30.hours.ago, updated_at: 2.minutes.ago }
  let!(:version_3) { create :version, state: 'accepted', created_at: 50.hours.ago, updated_at: 3.minutes.ago }
  let!(:version_4) { create :version, state: 'deleted', created_at: 55.hours.ago, updated_at: 4.minutes.ago }

  let!(:moderator) { create :user, :versions_moderator }

  before do
    allow(view.h).to receive(:params)
      .and_return type: 'content', created_on: created_on
  end

  context 'no processed date' do
    let(:created_on) { nil }
    it do
      expect(view.processed.map(&:object)).to eq [version_1, version_3, version_4]
      expect(view.postloader?).to eq false
      expect(view.pending).to have(1).item
      expect(view.moderators).to eq [moderator]
    end
  end

  context 'with processed date' do
    let(:created_on) { 2.days.ago.to_date.to_s }
    it do
      expect(view.processed.map(&:object)).to eq [version_3, version_4]
      expect(view.postloader?).to eq false
      expect(view.pending).to have(1).item
      expect(view.moderators).to eq [moderator]
    end
  end
end
