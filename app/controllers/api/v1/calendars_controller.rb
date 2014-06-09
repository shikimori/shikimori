class Api::V1::CalendarsController < Api::V1::ApiController
  respond_to :json

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/calendar", "Show a calendar"
  def show
    @collection = OngoingsQuery.new.fetch
    respond_with @collection, each_serializer: CalendarEntrySerializer
  end
end
