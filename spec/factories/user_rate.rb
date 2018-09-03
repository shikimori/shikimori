FactoryBot.define do
  factory :user_rate do
    status { :planned }
    target { create :anime }
    user { seed :user }
    episodes { 0 }
    volumes { 0 }
    chapters { 0 }

    UserRate.statuses.each_key do |user_rate_status|
      trait(user_rate_status.to_sym) { status { user_rate_status } }
    end
  end
end
