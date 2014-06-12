require 'spec_helper'

describe Device do
  describe :relations do
    it { should belong_to :user }
  end

  describe :validations do
    it { should validate_presence_of :user }
    it { should validate_presence_of :platform }
    it { should validate_presence_of :token }
  end
end
