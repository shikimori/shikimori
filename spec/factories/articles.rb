FactoryBot.define do
  factory :article do
    name { 'article name' }
    user { seed :user }
    text { 'article text' }
    moderation_state { 'pending' }
    approver_id { nil }
    tags { [] }
    locale { :ru }
  end
end
