class StudiosRepository < RepositoryBase
private

  def scope
    Studio.all
  end
end
