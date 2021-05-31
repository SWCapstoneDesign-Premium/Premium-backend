require 'optparse'

puts "################################################"
puts "#                                              #"
puts "#          Premium Backend Git Script          #"
puts "#             Made by YoonHaeng Heo            #"
puts "#                                              #"
puts "################################################"

puts "\n\n"

require 'optparse'

# Default values
options = {
  branch_name: '',
  int: 0,
  skip_pull: false,
  enum: '',
  array: {}
}

OptionParser.new do |opts|
  opts.banner = '--------- Usage: backend_script.rb [options] ----------'

  opts.on_head('   Options                               Description')
  opts.on('-b', '--branch_name branch_name', 'branch name - String type  (Default : \'\')') { |v| options[:branch_name] = v}
  opts.on('-s', '--[no-]boolean', 'Skip git pull - Boolean type(Default : false)'){ |v| options[:skip_pull] = v}
end.parse!

puts options
puts "\n"
puts "\n"
# unless branch_name.eql?("s")
#   exec ("git pull origin ")
puts "Execute git pull"
if options[:skip_pull]
  puts "Skip pull"
elsif !options[:branch_name].to_s.eql?("")
  str = "git pull origin '#{options[:branch_name]}'"
  system(str)
else
  puts "Enter branch to pull(Enter s skip this step)"
  branch_name = gets.chomp()
  str = "git pull origin '#{branch_name}'"
  system(str)
end


puts("git status")
system("git status")

puts "execute git add ."
system("git add .")
puts "--------------------"

puts "enter commit message"
commit_msg = gets.chomp()
system("git commit -m '#{commit_msg}'")

puts "git push"

if !options[:branch_name].to_s.eql?("")
  str2= "git push origin '#{options[:branch_name]}'"
else
  puts "Enter branch to push"
  p_branch_name = gets.chomp()
  str2 = "git push origin '#{p_branch_name}'"
end

system(str2)



