module ActiveRecord::ShikiHacks
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

ActiveRecord::Base.send :extend, ActiveRecord::ShikiHacks
