
require 'spec_helper'

describe Image do
  context '#relations' do
    it { should belong_to :uploader }
    it { should belong_to :owner }
  end

  context '#validations' do
    it { should have_attached_file :image }
    it { should validate_attachment_presence :image }
    it { should validate_presence_of :uploader }
    it { should validate_presence_of :owner }
  end

  describe 'deletion' do
    let(:user) { create :user }
    let(:uploader) { create :user }
    let(:owner) { create :group, :owner => user }
    let(:image) { create :image, :uploader => uploader, :owner => owner }

    it 'can be deleted by uploader' do
      image.can_be_deleted_by?(uploader).should be true
    end

    it 'can be deleted by random user' do
      image.can_be_deleted_by?(create :user).should be false
    end

    it 'can be deleted by owner permission' do
      user = create :user
      owner.admins << user
      image.can_be_deleted_by?(user).should be true
    end
  end
end
