FactoryBot.define do
  factory :webm_video do
    url { 'http://html5demos.com/assets/dizzy.webm' }
    state { 'pending' }

    WebmVideo.aasm.states.map(&:name).each do |value|
      trait(value.to_sym) { state { value } }
    end
  end
end
