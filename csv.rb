require 'csv'

x = CSV.foreach("test_14.csv") do |r|
  puts r
end
# source = "Name,Value\nfoo,0\nbar,1\nbaz,2\n"
# table = CSV.parse(source, headers: true)
# f = File.open("example", "w") do |file|
#   file.write(table.to_csv)
# end
# puts f
