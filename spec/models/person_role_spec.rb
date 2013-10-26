
require 'spec_helper'

describe PersonRole do
  it { should belong_to :anime }
  it { should belong_to :manga }
  it { should belong_to :character }
  it { should belong_to :person }
end

