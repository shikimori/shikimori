FactoryBot.define do
  factory :abuse_request do
    user { seed :user }

    comment { seed :comment }
    topic { nil }

    approver { nil }
    kind { 'offtopic' }
    state { 'pending' }
    value { true }

    factory :accepted_abuse_request do
      state { 'accepted' }
      approver { seed :user }
    end

    factory :rejected_abuse_request do
      state { 'rejected' }
      approver { seed :user }
    end
  end
end
