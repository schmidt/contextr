require "maruku"
gem "maruku"

$binding = binding

module MaRuKu
  Globals[:execute] = false
  Globals[:attach_output] = false
  Globals[:hide] = false

  module Out::HTML
    unless instance_methods.include? "to_html_code_using_pre_with_literate"
      def to_html_code_using_pre_with_literate(source)
        if get_setting(:execute)
          return_value = eval(source, $binding)
          source += "\n>> #{return_value}" if get_setting(:attach_output)
        end
        to_html_code_using_pre_without_literate(source) unless get_setting(:hide)
      end

      alias_method :to_html_code_using_pre_without_literate,
                   :to_html_code_using_pre
      alias_method :to_html_code_using_pre,
                   :to_html_code_using_pre_with_literate
    end
  end
end

module LiterateMarukuTest
  TARGET_DIR = File.dirname(__FILE__) + "/../../website/test/"

  extend self
  def load(file)
    maruku = Maruku.new(markdown_string(file))
    Dir.mkdir(TARGET_DIR) unless File.directory?(TARGET_DIR)
    File.open(TARGET_DIR + file + ".html", "w") do |f|
      f.puts maruku.to_html_document
    end
  end

  def markdown_string(file)
    File.open(File.dirname(__FILE__) + "/../#{file}.mkd"){|f| f.readlines.join}
  end
end
