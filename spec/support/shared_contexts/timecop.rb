shared_context :timecop do |datetime|
  if datetime
    before { Timecop.freeze Time.zone.parse(datetime) }
  else
    before do
      if defined? now
        Timecop.freeze Time.zone.parse(now)
      else
        Timecop.freeze
      end
    end
  end

  after { Timecop.return }
end
