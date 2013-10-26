require 'spec_helper'

describe UserNicknameChange do
  context '#relations' do
    it { should belong_to :user }
  end
end
