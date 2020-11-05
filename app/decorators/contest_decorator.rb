class ContestDecorator < DbEntryDecorator
  instance_cache :members, :displayed_round, :prior_round, :nearby_rounds,
    :suggestions, :median_votes, :user_suggestions,
    :matches_with_associations, :rounds

  # текущий раунд
  def displayed_round
    if h.params[:round]
      number = h.params[:round].to_i
      additional = !!(h.params[:round] =~ /a$/)
      object.rounds.find_by number: number, additional: additional
    else
      object.current_round
    end
  end

  # предыдущий раунд
  def prior_round
    displayed_round.prior_round
  end

  # соседние с текущим раунды
  def nearby_rounds
    [
      prior_round,
      displayed_round.next_round
    ].compact
  end

  # число участников в турнире
  def uniq_voters_count
    if started?
      @uniq_voters ||= Contests::UniqVotersCount.call self
    else
      cached_uniq_voters_count
    end
  end

  # сгруппированные по дням матчи
  def grouped_matches(round)
    @grouped_matches ||= {}
    @grouped_matches[round] ||= round
      .matches
      .includes(:left, :right)
      .map(&:decorate)
      .group_by(&:started_on)
  end

  # раунды
  def rounds
    object.rounds.includes matches: %i[left right]
  end

  # финальное голосование контеста
  def final_match
    rounds.last.matches.first
  end

  # # победители контеста
  # def results round=nil
    # strategy.results(round).take(winners_count).map(&:decorate)
  # end

  # # число победителей
  # def winners_count
    # links.count > 64 ? 32 : 16
  # end

  # отображать ли результаты
  def showing_results?
    object.finished? && h.params[:round].nil?
  end

  # голосования с аниме
  def matches_with target
    matches_with_associations.select do |match|
      match.left_id == target.id || match.right_id == target.id
    end
  end

  # текущий статус опроса
  def status
    if object.started?
      "#{object.human_state_name.capitalize} (#{object.current_round.title})"
    else
      object.human_state_name.capitalize
    end
  end

  # сгруппированные предложения для турнира от пользователей
  def suggestions
    object.suggestions
      .includes(:item)
      .by_votes
      .sort_by { |v| [-v.votes, h.localized_name(v.item)] }
  end

  def unordered_suggestions
    suggestions.sort_by { |v| h.localized_name(v.item) }
  end

  def median_votes
    suggestions.size > 10 ? suggestions[suggestions.size / 3].votes : 0
  end

  def certain_suggestions
    suggestions.select { |v| v.votes > median_votes }
  end

  def uncertain_suggestions
    suggestions.select { |v| v.votes <= median_votes }
  end

  # предложения к контесту от текущего пользователя
  def user_suggestions
    object.suggestions.includes(:item).by_user h.current_user
  end

  # новое предложение, добавляемое пользователем
  def new_suggestion
    object.suggestions.build item_type: object.member_klass.name
  end

  # может ли текущий пользователь предлагать ещё варианты
  def can_propose?
    user_suggestions.size < suggestions_per_user
  end

  # сколько ещё вариантов может предложить пользователь
  def proposals_left
    suggestions_per_user - user_suggestions.size
  end

  # урл для автозаполнения suggestion'а
  def suggestion_url
    object.anime? ? h.autocomplete_animes_url(search: '') : h.autocomplete_characters_url(search: '')
  end

  # текущий топ участников
  def rating round
    @rating ||= {}
    @rating[round] ||= begin
      matches_count = round.additional? ? round.matches.size * 2 : round.matches.size
      strategy.results(round).take [[[matches_count * 2, 8].max, 8].min, matches_count].max
    end
  end

  def rating_stats round
    prior_rating = round.prior_round ? rating(round.prior_round) : []

    rating(round).each_with_index.map do |member, index|
      prior_index = prior_rating.index member

      diff = prior_index == -1 || !prior_index ? 0 : prior_index - index

      OpenStruct.new(
        member: member,
        progress: diff.zero? ? nil : (diff.positive? ? "+#{diff}" : diff.to_s),
        status: diff.positive? ? :positive : :negative,
        position: index + 1
      )
    end
  end

  def members
    object.members.decorate
  end

  def winner_entries limit = nil
    scope = object.anime? ? anime_winners : character_winners
    scope.limit(limit).map(&:decorate)
  end

  def js_export
    matches = displayed_round&.matches&.select(&:started?)
    return [] unless h.user_signed_in? &&
      displayed_round&.started? && matches.present?

    votes = matches.map { |match| { match_id: match.id, vote: nil } }

    h.current_user.votes
      .where(votable_type: ContestMatch.name, votable_id: matches.map(&:id))
      .each_with_object(votes) do |vote, memo|
        memo.find { |v| v[:match_id] == vote.votable_id }[:vote] =
          ContestMatch::VOTABLE[vote.vote_flag]
      end
  end

private

  def matches_with_associations
    object.rounds
      .includes(matches: [:left, :right, round: :contest])
      .map(&:matches)
      .flatten
  end
end
