module Arel
  module Nodes
    class SelectStatement < Arel::Nodes::Node
      getter :cores
      property :limit, :orders, :lock, :offset, :with

      @cores = [] of Arel::Nodes::SelectCore

      def initialize(@cores = nil)
        super
      end

      def initialize_copy(other)
        super
        @cores  = @cores.map { |x| x.clone }
        @orders = @orders.map { |x| x.clone }
      end

      def hash
        [@cores, @orders, @limit, @lock, @offset, @with].hash
      end

      def eql?(other)
        self.class == other.class &&
          self.cores == other.cores &&
          self.orders == other.orders &&
          self.limit == other.limit &&
          self.lock == other.lock &&
          self.offset == other.offset &&
          self.with == other.with
      end

      def ==(other)
        eql?(other)
      end
    end
  end
end
