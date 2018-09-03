# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :contest_link do
    contest_id { 1 }
    linked_id { 1 }
    linked_type { 'MyString' }
  end
end
