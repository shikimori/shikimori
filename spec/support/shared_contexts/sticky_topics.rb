shared_context :sticky_topics do
  let(:offtopic_topic) { seed :offtopic_topic }

  let(:site_rules_topic) { seed :site_rules_topic }
  let(:description_of_genres_topic) { seed :description_of_genres_topic }
  let(:ideas_and_suggestions_topic) { seed :ideas_and_suggestions_topic }
  let(:site_problems_topic) { seed :site_problems_topic }
  let(:contests_proposals_topic) { seed :contests_proposals_topic }

  let(:all_sticky_topics) do
    [
      offtopic_topic,
      site_rules_topic,
      description_of_genres_topic,
      ideas_and_suggestions_topic,
      site_problems_topic,
      contests_proposals_topic
    ]
  end
end
