require_relative "../git-delta"

class Git::Delta::Runner
  def run(argv = ARGV)
    case ARGV.first
    when '-rails'
      rails
    when '-h', '--help'
      puts "This is just a quick script, check the readme or the source code"
    else
      Git::Delta::Reporter.new(*parse_arg(argv)).filter_out(exclude).report(@verbose)
    end
  end

  def parse_arg(argv)
    @verbose ||= ARGV.delete('-v')

    split = Hash.new{|h, k| h['path']}.merge!('.' => [], '-' => [], 'path' => [])
    argv.each{|a| split[a[0]] << a}

    split.values_at('path', '.', '-')
  end

  def exclude
    @excl ||= (File.read('./.ignore_commits') rescue File.read('tmp/.ignore_commits') rescue '')
  end

  def rails
    app = %w[app lib]
    categs = {
      js: [app, %w[js coffee hbs]],
      ruby: [app, %w[rb]],
      erb: [app, %w[erb haml]],
      app: [app, %w[erb haml rb js coffee hbs]],
      test: [%w[test spec], %w[rb]],
    }

    pmd = categs.map do |kind, args|
      Git::Delta::Reporter.new(*args).filter_out(exclude).plus_minus_delta
    end

    kinds = categs.keys

    # pmd << pmd.transpose.map{|s| s.inject(:+)}
    # kinds << 'total'
    categs.zip(pmd) do |(kind, (paths, extensions)), (p, m, d)|
      tot = total_lines(paths, extensions)
      puts "%10s: %4d %5d = %5d (%2.2f%% of %d)" % [kind, p, m, d, 100.0 * d / tot, tot]
    end
  end

  def total_lines(paths, extensions)
    paths.product(extensions).map do |path, ext|
      `find #{path} -name '*.#{ext}' -print0 | xargs -0 wc -l | tail -1`.to_i
    end.inject(:+)
  end
end

Git::Delta::Runner.new.run
