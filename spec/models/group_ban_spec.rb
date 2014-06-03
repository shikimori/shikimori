require 'spec_helper'

describe GroupBan do
  context :relations do
    it { should belong_to :group }
    it { should belong_to :user }
  end

  context :validations do
    it { should validate_presence_of :group }
    it { should validate_presence_of :user }
  end
end
