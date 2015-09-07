describe Moderation::VersionsItemTypeQuery do
  let(:query) { Moderation::VersionsItemTypeQuery.new type }

  let(:user) { create :user }
  let!(:version_1) { create :version, item: build_stubbed(:anime) }
  let!(:version_2) { create :version, item: build_stubbed(:manga) }
  let!(:version_3) { create :version, item: build_stubbed(:anime_video) }

  describe '#result' do
    subject { query.result }

    context 'content' do
      let(:type) { 'content' }
      it { is_expected.to eq [version_1, version_2] }
    end

    context 'anime_video' do
      let(:type) { 'anime_video' }
      it { is_expected.to eq [version_3] }
    end

    context 'unknown type' do
      let(:type) { 'zxc' }
      it { expect{subject}.to raise_error ArgumentError, 'unknown type: zxc' }
    end
  end
end
