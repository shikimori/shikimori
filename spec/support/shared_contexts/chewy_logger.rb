# frozen_string_literal: true

shared_context :chewy_logger do
  before do
    Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
  end
end
