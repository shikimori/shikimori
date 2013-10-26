require 'spec_helper'

describe UserImage do
  context '#relations' do
    it { should belong_to :user }
    it { should belong_to :linked }
  end

  context '#validations' do
    it { should validate_presence_of :user }
    it { should have_attached_file :image }
  end
end
