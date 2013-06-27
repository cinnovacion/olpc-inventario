require 'test_helper'
require 'excel'

class ExcelTest < ActiveSupport::TestCase
  test "generate" do
    titles = ["one", "two"]
    data = [["a", "b"], ["c", true], [1, 1.54]]
    filename = Excel.generate(data, titles)
    assert File.exist?(filename)
    File.delete filename
  end
end
