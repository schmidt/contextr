gem "literate_maruku"
require "literate_maruku"
require 'markaby'
require 'active_support'

class Fixnum
  def ordinal
    # teens
    return 'th' if (10..19).include?(self % 100)
    # others
    case self % 10
    when 1: return 'st'
    when 2: return 'nd'
    when 3: return 'rd'
    else    return 'th'
    end
  end
end

class Time
  def pretty
    return "#{mday}#{mday.ordinal} #{strftime('%B')} #{year}"
  end
end

module LiterateMarukuTest
  BASE_DIR = File.dirname(__FILE__) + "/../"
  TARGET_DIR = File.dirname(__FILE__) + "/../../website/test/"

  def self.load(file)
    content = LiterateMaruku.require(
                               BASE_DIR + "#{File.basename(file, '.rb')}.mkd", 
                               :inline => true,
                               :attributes => {:execute => true})

    download = "http://rubyforge.org/projects/contextr"
    version = ContextR::VERSION::STRING 
    modified = Time.now 
    sub_title = File.basename(file, '.rb').gsub("test_", "").titleize
    
    doc = Markaby::Builder.new.xhtml_strict do
      head do
        title "ContextR - #{sub_title} - Documentation"
        link :href => "../stylesheets/screen.css", :rel=>'stylesheet', 
             :type=>'text/css', :media => "screen"
        script :src => "../javascripts/rounded_corners_lite.inc.js",
              :type =>"text/javascript"
        script %Q{
          window.onload = function() {
            settings = {
                tl: { radius: 10 },
                tr: { radius: 10 },
                bl: { radius: 10 },
                br: { radius: 10 },
                antiAlias: true,
                autoPad: true,
                validTags: ["div"]
            }
            var versionBox = new curvyCorners(settings, 
                                              document.getElementById("version"));
            versionBox.applyCornersToAll();
          }
        }, :type => "text/javascript"
      end
      body do
        div.main! do
          h1 sub_title 
          div.version! :class => "clickable",
               :onclick => "document.location='#{download}'; return false" do
            p "Get Version"
            a version, :href => download, :class => "numbers"
          end
          h1 do
            self << "&#x2192; &#8216;"
            a "contextr", :href => "http://contextr.rubyforge.org/"
            self << "&#8217;" 
          end

          ul.navi! do
            Dir[File.dirname(file) + "/test_*.mkd"].each do |mkd_file_name|
              li do
                name = File.basename(mkd_file_name, ".mkd").gsub("test_", "")
                a name.titleize, :href => name + ".html" 
              end
            end
          end

          self << content
          p.coda do
            text modified.pretty
            br
            text "Theme extended from "
            a "Paul Battley", :href => "http://rb2js.rubyforge.org/"
          end
        end
      end
    end
    File.open(TARGET_DIR + 
            "#{File.basename(file, '.rb').gsub("test_", "")}.html", "w") do |f|
      f.puts(%q{<!DOCTYPE html
          PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
              "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">})
      doc.to_s.each do |chunk|
        f.puts(chunk)
      end
    end
  end
end
