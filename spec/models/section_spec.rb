require 'spec_helper'

describe Section do
  it { should have_many :topics }
end
