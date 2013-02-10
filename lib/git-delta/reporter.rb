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
        self
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
        if verbose
          data.each do |commit, plus, minus|
            puts ("%4d %5d = %5d  " % [plus, minus, plus + minus]) + commit
          end
          puts "** Warnings:", @warnings if @warnings && !@warnings.empty?
        end
        plus, minus, delta = plus_minus_delta
        puts "#{plus} #{minus} = #{delta}"
      end

      def data
        @data ||= self.class.parse_log(git_log).reverse
      end

    private
      def git_log
        extra = Array(extra_args).join(' ')
        extra << "--author=#{`git config user.email`.strip}" unless extra.include? '--author='
        `git log --oneline --shortstat --no-merges #{extra} -- #{file_filter}`
      end

      def file_filter
        p = Array(paths)
        p << '.' if p.empty?
        e = Array(extensions)
        e << nil if e.empty?
        p.product(e).map do |path, ext|
          next path if ext.nil?
          "'#{path}/*#{'.' unless ext.start_with?('.')}#{ext}'"
        end.join(' ')
      end

      def self.parse_log(log)
        log.lines.each_slice(2).map do |commit, changes|
          _, plus, minus = *changes.match(/.*changed,\s*(\d+ insertions\(\+\),?\s*)?(\d+ deletions\(\-\))?/)
          [commit.chomp, plus.to_i, -minus.to_i]
        end
      end
    end
  end
end
