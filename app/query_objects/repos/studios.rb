class Repos::Studios < Repos::RepositoryBase
private

  def scope
    Studio.all
  end
end
