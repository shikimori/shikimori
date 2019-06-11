shared_context :timecop do |value|
  if value
    before { Timecop.freeze Time.zone.parse(value) }
  else
    before do
      if defined? datetime
        Timecop.freeze Time.zone.parse(datetime)
      else
        Timecop.freeze
      end
    end
  end

  after { Timecop.return }
end
