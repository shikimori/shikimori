require 'spec_helper'

describe ContestUserVote do
  context :relations do
    it { should belong_to :match }
    it { should belong_to :user }
  end

  describe :validations do
    it { should validate_presence_of :match }
    it { should validate_presence_of :user }
  end
end
