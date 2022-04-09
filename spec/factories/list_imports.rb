FactoryBot.define do
  factory :list_import do
    user { seed :user }
    list { File.new "#{Rails.root}/spec/files/list.xml" }
    state { :pending }
    duplicate_policy { Types::ListImport::DuplicatePolicy[:replace] }
    list_type { Types::ListImport::ListType[:anime] }
    is_archived { false }

    after :build do |model|
      stub_method model, :schedule_worker
    end

    trait :with_schedule do
      after :build do |model|
        unstub_method model, :schedule_worker
      end
    end

    Types::ListImport::DuplicatePolicy.values.each do |value|
      trait(value) { duplicate_policy { value } }
    end
    Types::ListImport::ListType.values.each do |value|
      trait(value) { list_type { value } }
    end

    # ListImport.state_machine.states.map(&:value).each do |contest_state|
    #   trait(contest_state.to_sym) { state { contest_state } }
    # end

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
    trait :shiki_json_broken_2 do
      list { File.new "#{Rails.root}/spec/files/list_broken_2.json" }
    end
    trait :broken_file do
      list { File.new "#{Rails.root}/spec/files/broken_list.txt" }
    end

    trait :error_exception do
      failed
      output { { error: { type: ListImport::ERROR_EXCEPTION } } }
    end
    trait :error_empty_list do
      failed
      output { { error: { type: ListImport::ERROR_EMPTY_LIST } } }
    end
    trait :error_broken_file do
      failed
      output { { error: { type: ListImport::ERROR_BROKEN_FILE } } }
    end
    trait :error_mismatched_list_type do
      failed
      output { { error: { type: ListImport::ERROR_MISMATCHED_LIST_TYPE } } }
    end
    trait :error_missing_fields do
      failed
      output { { error: { type: ListImport::ERROR_MISSING_FIELDS, fields: %i[status] } } }
    end
  end
end
