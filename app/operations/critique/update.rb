# frozen_string_literal: true

class Critique::Update < ServiceObjectBase
  pattr_initialize :critique, :params, :actor

  def call
    is_updated = update_critique
    changelog if is_updated
    is_updated
  end

private

  def update_critique
    @critique.update update_params
  end

  def update_params
    @params.merge changed_at: Time.zone.now
  end

  def changelog
    NamedLogger.changelog.info(
      user_id: @actor.id,
      action: :update,
      critique: { 'id' => @critique.id },
      changes: @critique.saved_changes.except('updated_at', 'changed_at')
    )
  end
end
