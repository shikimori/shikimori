# module ActionDispatch::Routing::RouteSet::DispatcherFix
#   def call env
#     params = env[ActionDispatch::Routing::RouteSet::PARAMETERS_KEY]
#     params.each do |key,value|
#       next unless value.respond_to? :valid_encoding?
#       next if value.valid_encoding?
# 
#       russian = value.force_encoding 'cp1251'
#       params[key] = if russian.valid_encoding?
#         russian.encode 'utf-8'
#       else
#         value.fix_encoding
#       end
#     end
# 
#     super
#   end
# end
# 
# ActionDispatch::Routing::RouteSet::Dispatcher.send :prepend, ActionDispatch::Routing::RouteSet::DispatcherFix
