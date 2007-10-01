require "literate_maruku"

module MaRuKu
  Globals[:execute] = true
end
module LiterateMarukuTest
  BASE_DIR = File.dirname(__FILE__) + "/../"
  TARGET_DIR = File.dirname(__FILE__) + "/../../website/test/"

  def self.load(file)
    LiterateMaruku.require(BASE_DIR + "#{File.basename(file, '.rb')}.mkd", 
                           :output => TARGET_DIR)
  end
end
