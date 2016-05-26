module Arel
  macro alias_method(new_name, existing_method)
    def {{new_name.id}}(*args)
      {{existing_method.id}}(*args)
    end
  end
end
