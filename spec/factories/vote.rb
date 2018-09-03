FactoryBot.define do
  factory :vote, class: 'ActsAsVotable::Vote' do
    votable { FactoryBot.create(:anime) }
    voter { seed :user }
    vote_flag { true }
  end
end
