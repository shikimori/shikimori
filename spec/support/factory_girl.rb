module FactoryGirl
  module Syntax
    module Methods
      def stub_method model, name
        model.instance_variable_set :"@_#{name}", model.method(name)
        model.define_singleton_method(name) {}
      end

      def unstub_method model, name
        original_method = model.instance_variable_get :"@_#{name}"
        model.define_singleton_method(name) { original_method.call }
      end
    end
  end
end
