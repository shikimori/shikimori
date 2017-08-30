class Contests::UniqVotersCount
  method_object :contest

  def call
    Contests::Votes.call(@contest)
      .select('count(distinct(voter_id)) as uniq_voters')
      .to_a
      .first
      .uniq_voters
  end
end
