class Repos::Publishers < Repos::RepositoryBase
private

  def scope
    Publisher.all
  end
end
