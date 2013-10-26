module ActiveSupport
  module Cache
    class NoStore < Store
      def read_entry(name, options)
        return nil
      end

      def write_entry(name, value, options)
      end

      def delete_entry(name, options)
      end

      def clear
      end
    end
  end
end
