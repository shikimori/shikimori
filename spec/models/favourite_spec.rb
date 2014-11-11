
describe Favourite, :type => :model do
  it { should belong_to :linked }
  it { should belong_to :user }
end
