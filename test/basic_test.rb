require 'minitest/autorun'
require_relative '../lib/git-delta/reporter'

describe Git::Delta::Reporter do
  describe "parse_log" do
    it "works for Git version 1.8+" do
      log = <<EOL
b1982c2 - method_for_image
 1 file changed, 13 deletions(-)
da11c13 Refactor imagePicker.js
 13 files changed, 77 insertions(+), 401 deletions(-)
bf2311c + Handlebars.find
 1 file changed, 9 insertions(+)
EOL
      Git::Delta::Reporter.parse_log(log).must_equal [
        ["b1982c2 - method_for_image", 0, -13],
        ["da11c13 Refactor imagePicker.js", 77, -401],
        ["bf2311c + Handlebars.find", 9, 0],
      ]
    end
  end
end
