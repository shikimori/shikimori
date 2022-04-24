FactoryBot.define do
  factory :abuse_request do
    user { seed :user }

    comment { seed :comment }
    topic { nil }

    approver { nil }
    kind { Types::AbuseRequest::Kind[:offtopic] }
    state { Types::AbuseRequest::State[:pending] }
    value { true }

    AbuseRequest.kind.values.each do |kind_type|
      trait kind_type do
        kind { kind_type }
      end
    end

    AbuseRequest.aasm.states.map(&:name).each do |value|
      trait(value.to_sym) { state { value } }
    end

    factory :accepted_abuse_request do
      state { Types::AbuseRequest::State[:accepted] }
      approver { seed :user }
    end

    factory :rejected_abuse_request do
      state { Types::AbuseRequest::State[:rejected] }
      approver { seed :user }
    end
  end
end
