FactoryGirl.define do
  factory :abuse_request do
    user
    comment
    approver nil
    kind 'offtopic'
    state 'pending'
    value true

    factory :accepted_abuse_request do
      state 'accepted'
      approver factory: :user
    end
    factory :rejected_abuse_request do
      state 'rejected'
      approver factory: :user
    end
  end
end
