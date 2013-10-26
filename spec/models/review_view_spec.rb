require 'spec_helper'

describe ReviewView do
  it { should belong_to :user }
  it { should belong_to :review }
end
