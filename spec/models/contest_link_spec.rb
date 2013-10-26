require 'spec_helper'

describe ContestLink do
  context '#relations' do
    it { should belong_to :contest }
    it { should belong_to :linked }
  end
end
