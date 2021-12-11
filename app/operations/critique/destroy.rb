class Critique::Destroy
  method_object :critique, :actor

  def call
    changelog
    @critique.destroy
  end

private

  def changelog
    NamedLogger.changelog.info(
      user_id: @actor.id,
      action: :destroy,
      critique: @critique.attributes
    )
  end
end
