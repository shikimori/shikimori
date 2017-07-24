FactoryGirl.define do
  factory :list_import do
    user { seed :user }
    list { File.new "#{Rails.root}/spec/files/list.xml" }
    state :pending
    duplicate_policy Types::ListImport::DuplicatePolicy[:replace]
    list_type Types::ListImport::ListType[:anime]
    error nil

    after :build do |model|
      stub_method model, :schedule_worker
    end

    trait :with_schedule do
      after :build do |model|
        unstub_method model, :schedule_worker
      end
    end
  end
end
