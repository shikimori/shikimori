# базовый класс презентера
# TODO: выпилить все его проявления, заменив на декораторы через draper
class BasePresenter
  def self.inherited base
    # проксируем методы только для первого уровня иерархии
    if self.superclass != BasePresenter
      # алиас, т.к. class будет проксирован
      alias_method :presenter_class, :class
    end

    # список методов для проксирования
    base.instance_variable_set :@respond_proxy_methods, []
  end

  def initialize object=nil, view_context=nil
    @object = object
    @view_context = view_context

    # проксируем метод class
    self.presenter_class.send(:proxy, :class)
  end

  def entry
    @object
  end

  def object
    entry
  end

  def respond_to? method, include_private=false
    if respond_proxy_methods.include?(method) && @object.respond_to?(method)
      true
    else
      super method, include_private
    end
  end

private
  def self.presents name
    define_method name do
      @object
    end
  end

  def h text
    @view_context.send :h, text
  end

  # кастомный render_to_string, не затрагивающий основной контроллер
  def render_to_string options
    DummyRenderController.new(controller).render_to_string options
  end

  def method_missing method, *args, &block
    # проксирование методов среди, через class.respond_proxy *args
    if respond_proxy_methods.include?(method)
      @object.send(method, *args, &block)
    elsif @view_context.respond_to?(method)
      @view_context.send(method, *args, &block)
    else
      super
    end
  end

  # прокидывание указанных методов в презентуемый объект
  def self.proxy *names
    names.each do |name|
      define_method(name) do |*args|
        @object.send name, *args
      end
    end
  end

  # список методов для проксирования
  def respond_proxy_methods
    self.presenter_class.instance_variable_get(:@respond_proxy_methods)
  end

  # прокидывание указанных методов в презентуемый объект, если эти методы присутствуют в объекте
  def self.respond_proxy *names
    @respond_proxy_methods.concat names
  end
end
