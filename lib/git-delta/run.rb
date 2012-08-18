require "git-delta"

verbose = ARGV.delete('-v')

ext, paths, extra = [], [], []
split = Hash.new{|h, k| h['path']}.merge!('.' => [], '-' => [], 'path' => [])
ARGV.each{|a| split[a[0]] << a}

Git::Delta::Reporter.new(*split.values_at('path', '.', '-'))
.instance_eval do
  excl = (File.read('./.ignore_commits') rescue File.read('tmp/.ignore_commits') rescue '')
  filter_out(excl)
  report(verbose)
end
