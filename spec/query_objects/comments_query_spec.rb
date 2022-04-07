describe CommentsQuery do
  let(:query) { described_class.new Topic.name, topic.id }

  let!(:comment1) { create :comment, commentable: topic }
  let!(:comment2) { create :comment, commentable: topic }
  let!(:comment3) { create :comment, commentable: topic }
  let!(:comment4) { create :comment, commentable: topic }
  let!(:comment5) { create :comment, commentable: site_rules_topic }

  describe '#postload' do
    context 'desc' do
      context 'page_1' do
        subject { query.postload 1, 2, true }
        it { should eq [[comment4, comment3], true] }
      end

      context 'page_2' do
        subject { query.postload 2, 2, true }
        it { should eq [[comment2, comment1], false] }
      end
    end

    context 'asc' do
      subject { query.postload 1, 2, false }
      it { should eq [[comment1, comment2], true] }
    end
  end

  describe '#fetch' do
    context 'desc' do
      context 'page_1' do
        subject { query.fetch 1, 2, true }
        it { should eq [comment4, comment3, comment2] }
      end

      context 'page_2' do
        subject { query.fetch 2, 2, true }
        it { should eq [comment2, comment1] }
      end
    end

    context 'asc' do
      subject { query.fetch 1, 2, false }
      it { should eq [comment1, comment2, comment3] }
    end
  end
end
