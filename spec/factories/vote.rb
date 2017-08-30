FactoryGirl.define do
  factory :vote, class: 'ActsAsVotable::Vote' do
    votable { FactoryGirl.create(:anime) }
    voter { seed :user }
    vote_flag true
  end
end
