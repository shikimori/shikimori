require 'spec_helper'
require 'cancan/matchers'

describe Image do
  context :relations do
    it { should belong_to :uploader }
    it { should belong_to :owner }
  end

  context :validations do
    it { should have_attached_file :image }
    it { should validate_attachment_presence :image }
    it { should validate_presence_of :uploader }
    it { should validate_presence_of :owner }
  end

  describe :permissions do
    let(:user) { build_stubbed :user }
    let(:join_policy) { :free_join }
    subject { Ability.new user }

    context :uploader do
      let(:image) { build_stubbed :image, uploader: user }
      it { should be_able_to :destroy, image }
    end

    context :owner_editor do
      let(:club) { build_stubbed :group, owner: user }
      let(:image) { build_stubbed :image, owner: club }
      it { should be_able_to :destroy, image }
    end

    context :random_user do
      let(:image) { build_stubbed :image }
      it { should_not be_able_to :destroy, image }
    end
  end
end
