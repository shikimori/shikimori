require 'spec_helper'

describe CommentsQuery do
  let(:query) { CommentsQuery.new User.name, user.id }
  let(:user) { build_stubbed :user }
  let!(:comment1) { create :comment, user: user, commentable: user }
  let!(:comment2) { create :comment, user: user, commentable: user }
  let!(:comment3) { create :comment, user: user, commentable: user }
  let!(:comment4) { create :comment, user: user, commentable: user }
  let!(:comment5) { create :comment, user: user, commentable: build_stubbed(:user) }

  describe :postload do
    describe :desc do
      describe :page_1 do
        subject { query.postload 1, 2, true }
        it { should eq [[comment4, comment3], true] }
      end

      describe :page_2 do
        subject { query.postload 2, 2, true }
        it { should eq [[comment2, comment1], false] }
      end
    end

    describe :asc do
      subject { query.postload 1, 2, false }
      it { should eq [[comment1, comment2], true] }
    end
  end

  describe :fetch do
    describe :desc do
      describe :page_1 do
        subject { query.fetch 1, 2, true }
        it { should eq [comment4, comment3, comment2] }
      end

      describe :page_2 do
        subject { query.fetch 2, 2, true }
        it { should eq [comment2, comment1] }
      end
    end

    describe :asc do
      subject { query.fetch 1, 2, false }
      it { should eq [comment1, comment2, comment3] }
    end
  end
end
