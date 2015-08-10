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
      let!(:version_2) { create :version, item: anime, item_diff: { 'russian' => [] } }

      it { expect(query.by_field :name).to eq [version_1] }
    end

    describe 'ordering' do
      let!(:version_1) { create :version, item: anime, created_at: 2.days.ago }
      let!(:version_2) { create :version, item: anime, created_at: 1.day.ago }

      it { expect(query.by_field :name).to eq [version_2, version_1] }
    end
  end
end
