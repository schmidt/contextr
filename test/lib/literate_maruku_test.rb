require "literate_maruku"

module LiterateMarukuTest
  BASE_DIR = File.dirname(__FILE__) + "/../"
  TARGET_DIR = File.dirname(__FILE__) + "/../../website/test/"

  def self.load(file)
    LiterateMaruku.require(BASE_DIR + "#{File.basename(file, '.rb')}.mkd", 
                           :output => TARGET_DIR,
                           :attributes => {:execute => true})
  end
end
