class Contest::SwissStrategy < Contest::DoubleEliminationStrategy
  def dynamic_rounds?
    true
  end

  def with_additional_rounds?
    false
  end

  def total_rounds
    @total_rounds ||= Math.log(@contest.members.count, 2).ceil + 2
  end

  def fill_round_with_matches round
    if round.first?
      super
    else
      create_matches(
        round,
        @contest.members.size.times.map { ContestMatch::UNDEFINED },
        group: round.last? ? ContestRound::F : ContestRound::W,
        date: round.prior_round.matches.last.finished_on +
          @contest.matches_interval.days
      )
    end
  end

  def advance_members round, prior_round
    members = @statistics.sorted_scores
    members_ids    = members.keys
    members_scores = members.values

    ids_len = members_ids.length
    paired_ids = Array.new(ids_len)
    paired_ids_indx = 0

    next_group = 0
    next_group_score = members_scores[0]
    while next_group < ids_len
      group_start = next_group
      group_score = next_group_score

      i = group_start + 1
      while i < ids_len
        break unless group_score == members_scores[i]
        i += 1
      end
      next_group = i
      next_group_score = members_scores[i]
      group_len = next_group - group_start
                                                # indicates that first element of next group should actually belong to previous group
      top_of_next_is_from_prev = group_len.odd? # and was placed in next group only due to odd number of elements in previous group
      if top_of_next_is_from_prev
        if ids_len - group_start == 1        # if only one element left. Just in case. To prevent infinite loop,
          next_group = group_start           # when there were odd number of elements in members_ids.
          break
        else
          group_len -= 1
          next_group -= 1
        end
      end

      group_ids = members_ids.slice(group_start, group_len)
      half = group_len >> 1
      delta = 0
      opponents_of_id_in_question = @statistics.opponents_of(group_ids.first)
      while group_len.positive?   # will search from center, i. e. if length is 6: 3, 2, 4, 1, 5 and 0 stops
        i = half + delta
        if opponents_of_id_in_question.include?(group_ids[i])
          delta += 1
          i = half - delta
          if i.zero?         # if can't find a pair in this group
            k = next_group
            while k < ids_len
              break unless opponents_of_id_in_question.include?(members_ids[k])
              k += 1
            end

            if k == ids_len                # no pair can be found in entire rest of ids
              j = 0                        # so we just put back unpaired ids into members_ids
              k = next_group - group_len
              while k < next_group
                members_ids[k] = group_ids[j]
                j += 1
                k += 1
              end
              next_group -= group_len
              break
            end

            if top_of_next_is_from_prev
              if k == next_group              # pair with top of next group
                paired_ids[paired_ids_indx]     = group_ids.shift
                paired_ids[paired_ids_indx + 1] = members_ids[k]
                paired_ids_indx += 2
                members_ids[k] = group_ids.pop   # new top of next group from previous' bottom
                group_len -= 2
                half -= 1
              else
                paired_ids[paired_ids_indx]     = group_ids.shift
                paired_ids[paired_ids_indx + 1] = members_ids.delete_at(k)
                paired_ids_indx += 2
                                               members_scores.delete_at(k)
                ids_len -= 1
                group_ids.push(members_ids[next_group])   # put back an odd element to its native group
                next_group += 1
                top_of_next_is_from_prev = false
              end
            else     # odinary case
              next_group -= 1
              members_ids[next_group] = group_ids.pop     # odd element drops out into next group
              top_of_next_is_from_prev = true
              paired_ids[paired_ids_indx]     = group_ids.shift
              paired_ids[paired_ids_indx + 1] = members_ids.delete_at(k)
              paired_ids_indx += 2
                                             members_scores.delete_at(k)
              group_len -= 2
              half -= 1
              ids_len -= 1
            end

            delta = 0
            opponents_of_id_in_question = @statistics.opponents_of(group_ids.first)
            next
          end
          next if opponents_of_id_in_question.include?(group_ids[i])
        end

        # pair is found
        paired_ids[paired_ids_indx + 1] = group_ids.delete_at(i)
        paired_ids[paired_ids_indx]     = group_ids.shift
        paired_ids_indx += 2
        group_len -= 2
        half -= 1
        delta = 0
        opponents_of_id_in_question = @statistics.opponents_of(group_ids.first)
      end

      break if group_len.positive?  # means we have exited because no pair can be found in entire rest of ids
    end

    if next_group < ids_len       # There are some unpaired elements left
      # here should be algorithm for complete avoidance of repeated matches even in bottom of list
      # but for now, simple algo from previous version of match maker
      rest_len = ids_len - next_group
      rest_ids = members_ids.slice(next_group, rest_len)
      while rest_len.positive?
        left_id = rest_ids.shift
        rest_len -= 1
        paired_ids[paired_ids_indx] = left_id
        paired_ids_indx += 1
        break if rest_len <= 0
        right_id = (rest_ids - @statistics.opponents_of(left_id)).first

        if right_id
          rest_ids.delete right_id
        else
          right_id = members_ids.shift
        end
        rest_len -= 1
        paired_ids[paired_ids_indx] = right_id
        paired_ids_indx += 1
      end
    end

    i = 0
    round.matches.each do |match|
      left_id  = paired_ids[i]
      right_id = paired_ids[i + 1]
      i += 2

      match.update!(
        left_id: left_id,
        left_type: @contest.member_klass.name,
        right_id: right_id,
        right_type: @contest.member_klass.name
      )
    end
  end

  def advance_loser match
  end

  def advance_winner match
  end

  def results round = nil
    @statistics.sorted_scores(round).map do |id, scores|
      @statistics.members[id]
    end
  end
end
