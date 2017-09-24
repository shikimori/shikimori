shared_context :timecop do |datetime|
  if datetime
    before { Timecop.freeze Time.zone.parse(datetime) }
  else
    before { Timecop.freeze }
  end

  after { Timecop.return }
end
