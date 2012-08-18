module Git
  module Delta
    class Reporter < Struct.new(:paths, :extensions, :extra_args)
      attr_reader :verbose

      def filter_out(exclude)
        exclude = exclude.split("\n") unless exclude.respond_to? :map
        w = exclude.map do |skip|
          n = data.size
          data.delete_if{|commit, _, _| commit.include?(skip)}
          case n -= @data.size
          when 1
          when 0
            "Didn't find commit '#{skip}'" if ARGV.size <= 1
          else
            "Commit '#{skip}' matched #{n} commits"
          end
        end.compact
        (@warnings ||= []).concat(w)
      end

      def delta
        plus_minus_delta.last
      end

      def plus_minus_delta
        deltas = data.map{|_, plus, minus| plus + minus }
        deletions = deltas.select{|d| d < 0}.inject(0, :+)
        delta = deltas.inject(0, :+)
        [delta - deletions, deletions, delta]
      end

      def report(verbose = false)
        data.each do |commit, plus, minus|
          puts ("%4d %5d = %5d  " % [plus, minus, plus + minus]) + commit
        end if verbose
        plus, minus, delta = plus_minus_delta
        puts "#{plus} #{minus} = #{delta}"
        puts "** Warnings:", @warnings if @warnings && !@warnings.empty?
      end

      def data
        @data ||= parse_log(git_log)
      end

    private
      def git_log
        extra = extra_args.join(' ')
        extra << "--author=#{`git config user.email`.strip}" unless extra.include? '--author='
        puts "git log --oneline --shortstat --no-merges #{extra} -- #{file_filter}"
        `git log --oneline --shortstat --no-merges #{extra} -- #{file_filter}`
      end

      def file_filter
        p = Array(paths)
        p << '.' if p.empty?
        e = Array(extensions)
        e << nil if e.empty?
        p.product(e).map do |path, ext|
          next path if ext.nil?
          [path, '/*', ext.start_with?('.') || '.', ext].join
        end.join(' ')
      end

      def parse_log(log)
        log.lines.each_slice(2).map do |commit, changes|
          _, plus, minus = *changes.match(/.*changed, (\d+) insertions.* (\d+) deletions/)
          [commit, plus.to_i, -minus.to_i]
        end.reverse
      end
    end
  end
end
