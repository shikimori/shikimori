shared_context :seeds do
  let(:user) { seed :user }

  let(:offtopic_forum) { seed :offtopic_forum }
  let(:reviews_forum) { seed :reviews_forum }
  let(:animanga_forum) { seed :animanga_forum }
  let(:contests_forum) { seed :contests_forum }
  let(:clubs_forum) { seed :clubs_forum }
  let(:cosplay_forum) { seed :cosplay_forum }

  include_context :sticky_topics
end
