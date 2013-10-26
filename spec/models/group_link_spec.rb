require 'spec_helper'

describe GroupLink do
  context '#relations' do
    it { should belong_to :group }
    it { should belong_to :linked }
  end
end
