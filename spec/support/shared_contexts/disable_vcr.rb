# frozen_string_literal: true

# rubocop:disable Style/GlobalVars
shared_context :disable_vcr do
  if ENV['CI']
    before { raise 'Cannot disable VCR on CI server' }
  else
    before do
      $vcr_disabled = true
      VCR.configure { |c| c.ignore_request { |_request| $vcr_disabled } }
    end
    after { $vcr_disabled = false }
  end
end
# rubocop:enable Style/GlobalVars
