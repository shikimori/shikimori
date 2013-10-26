class ContestDecorator < Draper::Decorator
  delegate_all

  # текущий раунд
  def displayed_round
    @displayed_round ||= if h.params[:round]
      number = h.params[:round].to_i
      additional = !!(h.params[:round] =~ /a$/)
      object.rounds.where(number: number, additional: additional).first
    else
      object.current_round
    end
  end

  # предыдущий раунд
  def prior_round
    @prior_round ||= displayed_round.prior_round
  end

  # соседние с текущим раунды
  def nearby_rounds
    @nearby_rounds ||= [
      prior_round,
      displayed_round.next_round
    ].compact
  end

  # текущий матч
  def displayed_match
    @displayed_match ||= displayed_round.matches.where(id: h.params[:match_id]).first
  end

  # голоса за левый вариант
  def left_voters
    @left_voters ||= displayed_match.votes.includes(:user).where(item_id: displayed_match.left_id).map(&:user)
  end

  # голоса за правый вариант
  def right_voters
    @right_voters ||= displayed_match.votes.includes(:user).where(item_id: displayed_match.right_id).map(&:user)
  end

  # число участников в турнире
  def uniq_voters
    @uniq_voters ||= rounds.joins(matches: :votes).select('count(distinct(user_id)) as uniq_voters').first.uniq_voters
  end

  # голоса за правый вариант
  def refrained_voters
    @refrained_voters ||= displayed_match.votes.includes(:user).where(item_id: 0).map(&:user)
  end

  # сгруппированные по дням матчи
  def grouped_matches(round)
    @grouped_matches ||= {}
    @grouped_matches[round] ||= round
      .matches
      .with_user_vote(h.current_user, h.remote_addr)
      .includes(:left, :right)
      .map(&:decorate)
      .group_by(&:started_on)
  end

  # раунды
  def rounds
    @rounds ||= object.rounds.includes matches: [:left, :right]
  end

  # финальное голосование контеста
  def final_match
    rounds.last.matches.first
  end

  # описание контеста
  #def description
    #BbCodeService.instance.format_description(object.description, object).html_safe
  #end

  # победители контеста
  def results round=nil
    object.results(round).take winners_count
  end

  # число победителей
  def winners_count
    links.count > 64 ? 32 : 16
  end

  # отображать ли результаты
  def showing_results?
    object.finished? && h.params[:round].nil?
  end

  # голосования с аниме
  def matches_with target
    matches_with_associations.select {|v| v.left_id == target.id || v.right_id == target.id }
  end

  # изначально отображаемые комментарии
  def displayed_comments
    @displayed_comments ||= object.thread.comments.with_viewed(h.current_user).limit(15)
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
    @suggestions ||= object.suggestions.includes(:item).by_votes.sort_by {|v| [-v.votes, v.item.name] }
  end
  def median_votes
    @median_votes ||= suggestions.size > 10 ? suggestions[suggestions.size/2].votes : 0
  end
  def certain_suggestions
    suggestions.select {|v| v.votes > median_votes }
  end
  def uncertain_suggestions
    suggestions.select {|v| v.votes <= median_votes }
  end

  # предложения к контесту от текущего пользователя
  def user_suggestions
    @user_suggestions ||= object.suggestions.includes(:item).by_user h.current_user
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
      object.results(round).take [[[matches_count*2, 8].max, 8].min, matches_count].max
    end
  end

  def rating_stats round
    prior_rating = round.prior_round ? rating(round.prior_round) : []

    rating(round).each_with_index.map do |member,index|
      prior_index = prior_rating.index member

      diff = prior_index == -1 || !prior_index ? 0 : prior_index - index

      OpenStruct.new({
        member: member,
        progress: diff == 0 ? nil : (diff > 0 ? "+#{diff}" : "#{diff}"),
        status: diff > 0 ? :positive : :negative,
        position: index+1
      })
    end
  end

private
  def matches_with_associations
    @matches_with_associations ||= object.rounds.includes(matches: [ :left, :right, round: :contest ]).map(&:matches).flatten
  end
end
