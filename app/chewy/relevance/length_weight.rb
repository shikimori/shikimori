class Relevance::LengthWeight
  method_object :length

  LENGTH_MIN = 1.0
  LENGTH_MAX = 20.0

  SCORE_MIN = 1.0
  SCORE_MAX = 1.025

  def call
    percent = (@length - LENGTH_MIN) / (LENGTH_MAX - LENGTH_MIN)
    fixed_percent = [1, [percent, 0].max].min
    1.0 / (SCORE_MIN + (SCORE_MAX - SCORE_MIN) * fixed_percent)
  end
end
