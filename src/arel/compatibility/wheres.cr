module Arel
  module Compatibility
    class Wheres
      # include Enumerable

      module Value 
        property :visitor
        def value
          visitor.accept self
        end

        def name
          previous_def.to_sym
        end
      end

      def initialize(engine, collection)
        @engine     = engine
        @collection = collection
      end

      def each
        to_sql = Visitors::ToSql.new @engine

        @collection.each { |c|
          c.extend(Value)
          c.visitor = to_sql
          yield c
        }
      end
    end
  end
end
