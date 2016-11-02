module Arel
  module AliasPredication
    #TODO: Reimplement this method.
    #Crystal-lang uses "as" under the hood. Can not be redefined.

    def acting_as(other)
      Nodes::As.new self, Nodes::SqlLiteral.new(other)
    end
  end
end