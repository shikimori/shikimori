# require 'state_machine/version'
# 
# unless StateMachine::VERSION == '1.2.0'
#   # If you see this message, please test removing this file
#   # If it's still required, please bump up the version above
#   Rails.logger.warn "Please remove me, StateMachine version has changed"
# end
# 
# module StateMachine::Integrations::ActiveModel
#   public :around_validation
# end
# 
# # Hacks around https://github.com/pluginaweek/state_machine/issues/334
# module StateMachine
#   module Integrations
#     module ActiveRecord
#       def define_state_initializer
#         define_helper :instance, <<-end_eval, __FILE__, __LINE__ + 1
#           def initialize(*)
#             super do |*args|
#               self.class.state_machines.initialize_states self
#               yield(*args) if block_given?
#             end
#           end
#         end_eval
#       end
#     end
#   end
# end
