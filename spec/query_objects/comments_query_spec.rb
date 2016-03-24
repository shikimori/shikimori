describe CommentsQuery do
  let(:query) { CommentsQuery.new User.name, user.id, is_summary }
  let(:user) { build_stubbed :user }
  let(:is_summary) { false }
  let!(:comment1) { create :comment, :summary, user: user, commentable: user }
  let!(:comment2) { create :comment, user: user, commentable: user }
  let!(:comment3) { create :comment, :summary, user: user, commentable: user }
  let!(:comment4) { create :comment, user: user, commentable: user }
  let!(:comment5) { create :comment, user: user, commentable: build_stubbed(:user) }

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

    context 'summary' do
      let(:is_summary) { true }
      subject { query.fetch 1, 2, false }
      it { should eq [comment1, comment3] }
    end
  end
end
