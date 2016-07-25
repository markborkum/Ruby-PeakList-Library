require 'nokogiri'
require 'date'

module Bruker
  module XML
    # Contains functions for parsing and wrapping up groups pf peak lists
    class PLParser
      # Parses and wraps the details of a peak list header
      # ARGS
      #    ds : The raw contents of the "PeakList1DHeader" tag
      # RETURNS
      #    A new PickDetails object built from ds
      def parseDetails(ds)
        c = ds.content
        f1 = /F1=(.*)ppm, F2/.match(c)[1]
        f2 = /F2=(.*)ppm, MI/.match(c)[1]
        mi = /MI=(.*)cm, MAXI/.match(c)[1]
        mx = /MAXI=(.*)cm, PC/.match(c)[1]
        pc = /PC=(.*)/.match(c)[1]
        PickDetails.new(f1, f2, mi, mx, pc)
        return PickDetails.new(f1, f2, mi, mx, pc)
      end

      # Parses and wraps a group of peak lists
      # ARGS
      #    xmlDoc : The file path of the xml document to parse
      # RETURNS
      #    A list of new PeakList objects built from the contents of xmlDoc
      def parsePL(xmlDoc)
        @doc = Nokogiri::XML::Document.parse(File.open(xmlDoc))

        ls = []
        hs = []
        @doc.css("PeakList1D").each do |l_node|
          h = l_node.at_css("PeakList1DHeader")
          pd = h.at_css("PeakPickDetails")
          c = h.at_css("@creator")
          d = h.at_css("@date")
          x = h.at_css("@expNo")
          n = h.at_css("@name")
          o = h.at_css("@owner")
          p = h.at_css("@procNo")
          s = h.at_css("@source")
          dets = h.at_css("PeakPickDetails")
          dets = parseDetails(dets)
          h = ListHeader.new(c, d, x, n, o, p, s, dets)

          ps = l_node.css("Peak1D").to_a
          ps.map!{|p| Peak.new(p.at_css("@F1"), p.at_css("@intensity"), p.at_css("@type"))}
          ls << PeakList.new(h, ps)
        end

        return ls
      end
    end
  end

  # Wrapper around a list of peaks and their accompanying header
  class PeakList
     def initialize(header, peaks)
       @header = header
       @peaks = peaks
     end

     def display
       puts "#{@header.display}\n"
       @peaks.each {|elem| puts "#{elem.display}\n"}
       puts "------------------------------------------------------------\n"
     end
  end

  # Wrapper around a peak list's header
  class ListHeader
    def initialize(creator, date, expNo, name, owner, procNo, source, details)
      @creator = creator
      @date = DateTime.strptime(date, "%Y-%m-%dT%H:%M:%S")
      @expNo = expNo.value.to_i
      @name = name
      @owner = owner
      @procNo = procNo.value.to_i
      @source = source
      @details = details
    end

    def display
      puts "Creator: #{@creator}\nDate: #{@date}\nExpNo: #{@expNo}\nName: #{@name}\nOwner: #{@owner}\nProcNo: #{@procNo}\nSource: #{@source}\n#{@details.display}"
    end
  end

  # Wrapper around the parameters for peak selection
  class PickDetails
    def initialize(f1, f2, mi, maxi, pc)
      @F1 = f1
      @F2 = f2
      @MI = mi
      @MAXI = maxi
      @PC = pc
    end

    def display
      puts "F1: #{@F1}\tF2: #{@F2}\tMI: #{@MI}\tMAXI: #{@MAXI}\tPC: #{@PC}"
    end
  end

  # Wrapper around individual peak data
  class Peak
    def initialize(f1, intensity, type)
      @f1 = f1
      @intensity = intensity
      @type = type
    end

    def display
      puts "F1: #{@f1}\nIntensity: #{@intensity}\nType: #{@type}"
    end
  end
end
