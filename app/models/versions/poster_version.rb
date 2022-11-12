class Versions::PosterVersion < Version
  # FIELD = 'poster'

  Actions = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:upload, :delete)

  def action
    Actions[item_diff['action']]
  end
end
