describe Moderation::ProcessedVersionsQuery do
  let(:query) { Moderation::ProcessedVersionsQuery.new }

  let(:user) { create :user }
  let!(:version_1) { create :version, state: 'taken', id: 1 }
  let!(:version_2) { create :version, state: 'pending', id: 5 }
  let!(:version_3) { create :version, state: 'accepted', id: 3 }
  let!(:version_4) { create :version, state: 'deleted', id: 4 }

  describe '#fetch' do
    subject { query.fetch page, limit }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { should eq [version_1, version_3, version_4] }
    end

    context 'second_page' do
      let(:page) { 2 }
      it { should eq [version_4] }
    end
  end

  describe '#postload' do
    subject { query.postload page, limit }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { should eq [[version_1, version_3], true] }
    end

    context 'second_page' do
      let(:page) { 2 }
      it { should eq [[version_4], false] }
    end
  end
end

