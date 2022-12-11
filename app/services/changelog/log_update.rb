class Chanelog::LogUpdate
  method_object :model, :actor, %i[changes]

  def call
    changes = @changes ||
      @model.saved_changes.except('updated_at', 'changed_at')
    return if changes.blank?

    logger.info(
      user_id: @actor.id,
      action: :update,
      id: @model.id,
      changes: changes
    )
  end

private

  def logger
    @logger ||= NamedLogger.send(
      :"changelog_#{model.class.base_class.name.underscore.pluralize}"
    )
  end
end
