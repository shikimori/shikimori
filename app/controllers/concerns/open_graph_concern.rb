module OpenGraphConcern
  extend ActiveSupport::Concern

  included do
    helper_method :og
  end

  def og options = nil
    @open_graph ||= OpenGraphView.new

    if options&.any?
      options.each do |(key, value)|
        @open_graph.send :"#{key}=", value
      end
    end

    @open_graph
  end
end
