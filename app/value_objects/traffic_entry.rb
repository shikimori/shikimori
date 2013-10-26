class TrafficEntry < Struct.new(:date, :visitors, :visits, :page_views)
  def date
    DateTime.parse super
  end
end
