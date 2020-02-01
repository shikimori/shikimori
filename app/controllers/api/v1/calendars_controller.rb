class Api::V1::CalendarsController < Api::V1Controller
  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/calendar', 'Show a calendar'
  def show
    @collection = CalendarsQuery.new.fetch
    respond_with @collection, each_serializer: CalendarEntrySerializer
  end
end
