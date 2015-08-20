describe VersionsQuery do
  let(:query) { VersionsQuery.new anime }
  let(:anime) { build_stubbed :anime }

  describe '#all' do
    describe 'deleted' do
      let!(:pending) { create :version, item: anime }
      let!(:deleted) { create :version, item: anime, state: 'deleted' }

      it { expect(query.all).to eq [pending] }
    end

    describe 'another entry' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) { create :version, item: build_stubbed(:anime) }

      it { expect(query.all).to eq [version_1] }
    end

    describe 'ordering' do
      let!(:version_1) { create :version, item: anime, created_at: 2.days.ago }
      let!(:version_2) { create :version, item: anime, created_at: 1.day.ago }

      it { expect(query.all).to eq [version_2, version_1] }
    end
  end

  describe '#by_field' do
    describe 'deleted' do
      let!(:pending) { create :version, item: anime }
      let!(:deleted) { create :version, item: anime, state: 'deleted' }

      it { expect(query.by_field :name).to eq [pending] }
    end

    describe 'another entry' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) { create :version, item: build_stubbed(:anime) }

      it { expect(query.by_field :name).to eq [version_1] }
    end

    describe 'another field' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) { create :version, item: anime,
        item_diff: { 'russian' => [] } }

      it { expect(query.by_field :name).to eq [version_1] }
    end

    describe 'ordering' do
      let!(:version_1) { create :version, item: anime, created_at: 2.days.ago }
      let!(:version_2) { create :version, item: anime, created_at: 1.day.ago }

      it { expect(query.by_field :name).to eq [version_2, version_1] }
    end
  end

  describe '#authors' do
    let(:author_1) { create :user }
    let(:author_2) { create :user }
    let(:diff) {{ description: ['a','b'] }}

    describe 'accepted' do
      let!(:pending) { create :version, item_diff: diff, item: anime }
      let!(:accepted) { create :version, :accepted, user: author_1,
        item_diff: diff, item: anime }
      let!(:taken) { create :version, state: 'taken', item_diff: diff,
        item: anime }
      let!(:deleted) { create :version, state: 'deleted', item_diff: diff,
        item: anime }

      it { expect(query.authors :description).to eq [author_1] }
    end

    describe 'another entry' do
      let!(:accepted_1) { create :version, :accepted, user: author_1,
        item_diff: diff, item: anime }
      let!(:accepted_2) { create :version, :accepted, user: author_2,
        item_diff: diff, item: build_stubbed(:anime) }

      it { expect(query.authors :description).to eq [author_1] }
    end

    describe 'another field' do
      let!(:accepted_1) { create :version, :accepted, user: author_1,
        item_diff: diff, item: anime }
      let!(:accepted_2) { create :version, :accepted, user: author_2,
        item_diff: { name: [1,2] }, item: anime }

      it { expect(query.authors :description).to eq [author_1] }
    end

    describe 'ordering' do
      let!(:accepted_1) { create :version, :accepted, user: author_1,
        item_diff: diff, item: anime, created_at: 2.days.ago }
      let!(:accepted_2) { create :version, :accepted, user: author_2,
        item_diff: diff, item: anime, created_at: 1.day.ago }

      it { expect(query.authors :description).to eq [author_1, author_2] }
    end

    context 'screenshots' do
      let!(:upload) { create :version, :accepted, user: author_1,
        item_diff: { action: Versions::ScreenshotsVersion::ACTIONS[:upload],
        screenshots: ['a','b'] }, item: anime }
      let!(:delete) { create :version, :accepted, user: author_2,
        item_diff: { action: Versions::ScreenshotsVersion::ACTIONS[:delete],
        screenshots: ['a','b'] }, item: anime }
      let!(:reposition) { create :version, :accepted, user: author_2,
        item_diff: { action: Versions::ScreenshotsVersion::ACTIONS[:reposition],
        screenshots: ['a','b'] }, item: anime }

      it { expect(query.authors :screenshots).to eq [author_1] }
    end

    context 'videos' do
      let!(:upload) { create :version, :accepted, user: author_1,
        item_diff: { action: Versions::VideoVersion::ACTIONS[:upload],
        videos: ['a','b'] }, item: anime }
      let!(:delete) { create :version, :accepted, user: author_2,
        item_diff: { action: Versions::VideoVersion::ACTIONS[:delete],
        videos: ['a','b'] }, item: anime }

      it { expect(query.authors :videos).to eq [author_1] }
    end
  end
end
