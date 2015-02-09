# базовый класс для презентера с отложенной загрузкой
# TODO: выпилить
class LazyPresenter < BasePresenter
  def initialize(object=nil, template=nil)
    super object, template
    @loaded = false
  end

private
  def self.lazy_loaded(*names)
    names.each do |name|
      define_method(name) do
        lazy_load and @loaded = true unless @loaded
        instance_variable_get "@#{name}"
      end
    end
  end
end
