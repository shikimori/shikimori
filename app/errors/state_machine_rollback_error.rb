class StateMachineRollbackError < RuntimeError
  def initialize object, action
    super "Cannot execute action '#{action}' on #{object.class.name}##{object.id}"
  end
end
