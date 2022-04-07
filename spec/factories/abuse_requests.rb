FactoryBot.define do
  factory :abuse_request do
    user { seed :user }

    comment { seed :comment }
    topic { nil }

    approver { nil }
    kind { 'offtopic' }
    state { 'pending' }
    value { true }

    AbuseRequest.kind.values.each do |kind_type|
      trait kind_type do
        kind { kind_type }
      end
    end

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
