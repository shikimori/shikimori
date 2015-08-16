class Recommendations::Normalizations::NormalizationBase
  def initialize
    @means = {}
    @sigmas = {}
  end

  def mean scores, user_id
    @means[user_id] ||= _mean(scores)
  end

  def sigma scores, user_id
    @sigmas[user_id] ||= _sigma(scores)
  end

  #def score score, user_id, ratings
    #raise NotImplementedError
  #end

  #def restore_score score, user_id, ratings
    #raise NotImplementedError
  #end

  # mean, используемый для приведения реокмендованной оценке к 10 бальной шкале
  def restorable_mean scores
    0
  end

  # sigma, используемый для приведения реокмендованной оценке к 10 бальной шкале
  def restorable_sigma scores
    1
  end

private
  def _mean scores
    scores.sum * 1.0 / scores.size
  end

  # population standard deviation
  # Math.sqrt(scores.sum {|x| (x - x_mean) ** 2 } / scores.size)

  # standard deviation
  # Math.sqrt(scores.sum {|x| (x - x_mean) ** 2 } / (scores.size - 1))

  # dividing by n−1 gives a better estimate of the population standard deviation than dividing by n
  def _sigma scores
    x_mean = _mean(scores)
    Math.sqrt(scores.sum {|x| (x - x_mean) ** 2 } / (scores.size - 1))
  end
end
