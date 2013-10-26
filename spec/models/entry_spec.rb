require 'spec_helper'
describe Entry do
  context '#relations' do
    it { should belong_to :section }
    it { should belong_to :linked }
    it { should belong_to :user }
    it { should have_many :views }
    it { should have_many :messages }
  end

  context '#hooks' do
    let(:images) { 1.upto(4).map { create :user_image, user: user } }
    let(:entry) { create :entry, text: 'text', user: user, value: "#{images[0].id},#{images[1].id}" }

    describe 'append_wall' do
      it 'wall tag is appended' do
        entry.text.should eq "text\n[wall][url=#{images[0].image.url :original, false}][img]#{images[0].image.url :preview, false}[/img][/url][url=#{images[1].image.url :original, false}][img]#{images[1].image.url :preview, false}[/img][/url][/wall]"
      end
    end

    describe 'destroy_images' do
      before { entry }
      it 'all images are destroyed' do
        expect {
          entry.destroy
        }.to change(UserImage, :count).by -2
      end
    end

    describe 'claim_images' do
      before { entry }
      it 'all images are claimed' do
        images[0].reload.linked.should eq entry
      end
    end

    describe 'unclaim_images' do
      let(:entry) { create :entry, text: 'text', user: user, value: "#{images[0].id},#{images[1].id},#{images[2].id},#{images[3].id}" }
      before { entry }

      it 'unused images are destroyed' do
        expect {
          entry.user_image_ids = [images[0].id, images[1].id]
          entry.save
        }.to change(UserImage, :count).by -2
      end
    end
  end

  let (:user) { create :user }
  let (:user2) { create :user }
  let (:entry) { create :entry, user: user }

  describe 'user_images' do
    let(:images) { 1.upto(3).map { create :user_image, user: user } }
    let(:entry) { create :entry, user: user, value: "#{images[0].id},#{images[2].id},#{images[1].id}" }

    it 'returns user images stored in value in correct order' do
      entry.user_images.should eq [images[0], images[2], images[1]]
    end
  end

  describe 'comment is deleted' do
    it 'updated_at is set to created_at of last comment' do
      first = second = third = nil
      Comment.wo_antispam do
        first = create :comment, commentable: entry, created_at: DateTime.now - 2.days, body: 'first'
        second = create :comment, commentable: entry, created_at: DateTime.now - 1.day, body: 'second'
        third = create :comment, commentable: entry, created_at: DateTime.now - 30.minutes, body: 'third'
      end
      third.destroy
      Entry.last.updated_at.to_i.should eq(second.created_at.to_i)
    end
  end

  describe 'comments selected with viewed flag' do
    before do
      @comment = create :comment, commentable: entry, user: user
    end

    it 'false' do
      entry.comments.with_viewed(user2).first.viewed?.should be_false
    end

    it 'true' do
      create :comment_view, comment: @comment, user: user2
      entry.comments(user2).first.viewed?.should be_true
    end
  end

  describe 'permissions' do
    describe 'with owner' do
      it 'can be edited' do
        entry.can_be_edited_by?(user).should be_true
      end

      describe 'can be deleted' do
        context 'old' do
          before { entry.update_column :created_at, 1.month.ago }
          it { entry.can_be_deleted_by?(user).should be_false }
        end

        context 'new' do
          it { entry.can_be_deleted_by?(user).should be_true }
        end
      end
    end

    describe 'with admin' do
      let (:admin_user) { create :user }

      before do
        admin_user.stub(:admin?).and_return(true)
        admin_user.stub(:moderator?).and_return(true)
      end

      it 'can be edited' do
        entry.can_be_edited_by?(admin_user).should be_true
      end

      it 'can be deleted' do
        entry.can_be_deleted_by?(admin_user).should be_true
      end
    end


    describe 'with random user' do
      let (:random_user) { create :user }

      it "can't be edited" do
        entry.can_be_edited_by?(random_user).should be_false
      end

      it "can't be deleted" do
        entry.can_be_deleted_by?(random_user).should be_false
      end
    end
  end
end
