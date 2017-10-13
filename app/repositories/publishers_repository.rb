class PublishersRepository < RepositoryBase
private

  def scope
    Publisher.all
  end
end
