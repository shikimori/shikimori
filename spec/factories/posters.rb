FactoryBot.define do
  factory :poster do
    anime { nil }
    manga { nil }
    character { nil }
    person { nil }
    image_data { File.new "#{Rails.root}/spec/files/poster.jpg" }
  end
end
