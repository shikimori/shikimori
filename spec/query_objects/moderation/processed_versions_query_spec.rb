describe Moderation::ProcessedVersionsQuery do
  let(:query) { Moderation::ProcessedVersionsQuery.new 'content' }

  let(:user) { create :user }
  let!(:version_1) { create :version, state: 'taken', updated_at: 1.minute.ago }
  let!(:version_2) { create :version, state: 'pending', updated_at: 2.minutes.ago }
  let!(:version_3) { create :version, state: 'accepted', updated_at: 3.minutes.ago }
  let!(:version_4) { create :version, state: 'deleted', updated_at: 4.minutes.ago }

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
