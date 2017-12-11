if ENV['RAILS_LOG_TO_STDOUT'].present?
  Chewy.logger = ActiveSupport::Logger.new(STDOUT)
  Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
elsif Rails.env.development?
  Chewy.logger = NamedLogger.chewy
  Chewy.transport_logger = NamedLogger.elasticsearch
end
