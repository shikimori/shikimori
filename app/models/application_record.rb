class ApplicationRecord < ActiveRecord::Base
  extend Enumerize
  extend BooleanAttribute

  self.abstract_class = true

  def wo_timestamp
    old = record_timestamps
    self.record_timestamps = false
    begin
      yield
    ensure
      self.record_timestamps = old
    end
  end
end
