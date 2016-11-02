require "../src/arel.cr"

puts "Testing Crystal"

table = Arel::Table.new("prompts")
table.from