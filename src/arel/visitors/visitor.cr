module Arel
  module Visitors
    class Visitor
      def initialize
        @dispatch = get_dispatch_cache
      end

      def accept(object)
        visit(object)
      end

      # private

      def self.dispatch_cache
        Hash.new do |hash, klass|
          hash[klass] = "visit_#{(klass.name || "").gsub("::", "_")}"
        end
      end

      def get_dispatch_cache
        self.class.dispatch_cache
      end

      def dispatch
        @dispatch
      end

      def visit(object)
        send dispatch[object.class], object
      rescue e : NoMethodError
        raise e if respond_to?(dispatch[object.class], true)
        superklass = object.class.ancestors.find { |klass|
          respond_to?(dispatch[klass], true)
        }
        raise(TypeError, "Cannot visit #{object.class}") unless superklass
        dispatch[object.class] = dispatch[superklass]
        #CRYSTAL
        #Not yet supported as of 0.14.1
        # retry
      end
    end
  end
end
