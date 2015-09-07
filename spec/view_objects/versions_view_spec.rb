describe VersionsView do
  let(:view) { VersionsView.new }

  let!(:version_1) { create :version, state: 'taken', created_at: 1.minute.ago }
  let!(:version_2) { create :version, state: 'pending', created_at: 2.minutes.ago }
  let!(:version_3) { create :version, state: 'accepted', created_at: 3.minutes.ago }
  let!(:version_4) { create :version, state: 'deleted', created_at: 4.minutes.ago }

  let!(:moderator) { create :user, :versions_moderator }

  before { view.h.params[:type] = 'content' }

  it do
    expect(view.processed).to have(3).items
    expect(view.postloader?).to eq false
    expect(view.pending).to have(1).item
    expect(view.moderators).to eq [moderator]
  end
end
