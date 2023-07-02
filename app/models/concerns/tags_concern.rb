module TagsConcern
  extend ActiveSupport::Concern

  def tags= value
    super value&.map { |tag| Tags::CleanupForumTag.call tag }
  end
end
