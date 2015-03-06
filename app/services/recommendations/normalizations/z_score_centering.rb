class Recommendations::Normalizations::ZScoreCentering < Recommendations::Normalizations::ZScore
  def sigma scores, user_id
    @sigmas[user_id] ||= begin
      x_mean = mean scores, user_id
      Math.sqrt(scores.sum {|x| (x - x_mean) ** 2 } / scores.size)
    end
  end
end
