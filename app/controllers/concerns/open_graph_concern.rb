module OpenGraphConcern
  extend ActiveSupport::Concern

  included do
    helper_method :og
    delegate :page_title, :noindex, :nofollow, :description, :keywords,
      to: :og
  end

  def og *args
    @open_graph ||= OpenGraphView.new

    args.each do |(key, value)|
      @open_graph.send "#{key}=", value
    end

    @open_graph
  end
end
