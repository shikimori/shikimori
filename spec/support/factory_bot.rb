module FactoryBot
  module Syntax
    module Methods
      def stub_method model, name
        model.instance_variable_set(
          :"@_#{name.to_s.gsub /!/, 'ZZZ'}",
          model.method(name)
        )
        model.define_singleton_method(name) {}
      end

      def unstub_method model, name
        original_method = model.instance_variable_get(
          :"@_#{name.to_s.gsub /!/, 'ZZZ'}"
        )
        model.define_singleton_method(name) { |*args| original_method.call *args }
      end
    end
  end
end
