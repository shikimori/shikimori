class Review::Update
  method_object %i[model! params! faye!]

  def call
    is_updated = @faye.update @model, fixed_params
    Changelog::LogUpdate.call @model, @faye.actor if is_updated
    is_updated
  end

private

  def fixed_params
    if @model.db_entry_released_before?
      params
    else
      params.except(:is_written_before_release)
    end
  end
end
