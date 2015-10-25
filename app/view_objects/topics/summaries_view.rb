class Topics::SummariesView < Topics::View
  def comments
    Topics::Comments.new(
      topic: topic,
      only_summaries: true,
      is_preview: is_preview
    )
  end
end
