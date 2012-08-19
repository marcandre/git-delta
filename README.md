# Git::Delta

Outputs the net number of lines added/removed by you for the current `git` directory.

It sums the net change for each commit and output the sum of positive and negative contributions:

	$ git-delta
	123 - 100 = 23

The commits that made net contributions totalled 123 extra lines. The commits that made net code reductions removed a total of 100 lines.
Net lines added: 23

## Installation

    gem install 'git-delta'

## Usage

	$ git-delta app lib
	$ git-delta .js .coffee
	$ git-delta --author=someone_else

	$ git-delta -v
	$ git-delta -rails

Other options starting with `-` are passed on to `git`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
