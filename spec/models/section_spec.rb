
require 'spec_helper'

describe Section do
  it { should belong_to :forum }
  it { should have_many :topics }
end
