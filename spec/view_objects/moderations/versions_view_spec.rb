describe Moderations::VersionsView do
  include_context :timecop, '2016-03-18 15:00:00'
  include_context :view_context_stub

  let(:view) { described_class.new }

  let!(:version_1) do
    create :version, :taken,
      created_at: 15.hours.ago,
      updated_at: 1.minute.ago
  end
  let!(:version_2) do
    create :version, :pending,
      created_at: 30.hours.ago,
      updated_at: 2.minutes.ago
  end
  let!(:version_3) do
    create :version, :accepted,
      created_at: 50.hours.ago,
      updated_at: 3.minutes.ago
  end
  let!(:version_4) do
    create :version, :deleted,
      created_at: 55.hours.ago,
      updated_at: 4.minutes.ago
  end

  let!(:moderator) { create :user, :version_names_moderator }

  let(:view_context_params) do
    {
      type: 'names',
      created_on: created_on
    }
  end

  context 'no processed date' do
    let(:created_on) { nil }
    it do
      expect(view.processed).to eq [version_1, version_3, version_4]
      expect(view.pending).to eq [version_2]
      expect(view.moderators).to eq [moderator]
    end
  end

  context 'with processed date' do
    let(:created_on) { 2.days.ago.to_date.to_s }
    it do
      expect(view.processed).to eq [version_3, version_4]
      expect(view.pending).to eq [version_2]
      expect(view.moderators).to eq [moderator]
    end
  end
end
