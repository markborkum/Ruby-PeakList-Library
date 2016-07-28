require 'minitest/autorun'
require 'nokogiri'

require 'bruker'

class TestParse < Minitest::Test
  def test_parse
    filename = 'tests/peaklist.xml'
    
    File.open(filename) { |file|
      document = Nokogiri.XML(file)
      
      bruker_document = Bruker.XML(document)
      
      assert_not_nil(bruker_document)
    }
  end
end
