FactoryGirl.define do
  factory :list_import do
    user { seed :user }
    list { File.new "#{Rails.root}/spec/files/list.xml" }
    state :pending
    duplicate_policy Types::ListImport::DuplicatePolicy[:replace]
    list_type Types::ListImport::ListType[:anime]

    after :build do |model|
      stub_method model, :schedule_worker
    end

    trait :with_schedule do
      after :build do |model|
        unstub_method model, :schedule_worker
      end
    end

    Types::ListImport::DuplicatePolicy.values.each do |value|
      trait(value) { duplicate_policy value }
    end
    Types::ListImport::ListType.values.each do |value|
      trait(value) { list_type value }
    end

    trait :mal_xml do
      list { File.new "#{Rails.root}/spec/files/list.xml" }
    end
    trait :mal_xml_gz do
      list { File.new "#{Rails.root}/spec/files/list.xml.gz" }
    end
    trait :shiki_json do
      list { File.new "#{Rails.root}/spec/files/list.json" }
    end
    trait :shiki_json_gz do
      list { File.new "#{Rails.root}/spec/files/list.json.gz" }
    end

    trait :shiki_json_empty do
      list { File.new "#{Rails.root}/spec/files/list_empty.json" }
    end
    trait :shiki_json_broken do
      list { File.new "#{Rails.root}/spec/files/list_broken.json" }
    end

    ListImport.state_machine.states.map(&:value).each do |contest_state|
      trait(contest_state.to_sym) { state contest_state }
    end
  end
end
