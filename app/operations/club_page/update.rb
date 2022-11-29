class ClubPage::Update
  method_object :model, :params, :actor

  def call
    is_updated = @model.update @params
    Changelog::LogUpdate.call @model, @actor if is_updated
    is_updated
  end
end
