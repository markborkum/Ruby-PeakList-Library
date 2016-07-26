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
      #    A new PeakPickDetails object built from ds
      def parseDetails(ds)
        c = ds.content
        f1 = /F1=(.*)ppm, F2/.match(c)[1]
        f2 = /F2=(.*)ppm, MI/.match(c)[1]
        mi = /MI=(.*)cm, MAXI/.match(c)[1]
        mx = /MAXI=(.*)cm, PC/.match(c)[1]
        pc = /PC=(.*)/.match(c)[1]
        PeakPickDetails.new(f1, f2, mi, mx, pc)
        return PeakPickDetails.new(f1, f2, mi, mx, pc)
      end

      # Parses and wraps a group of peak lists
      # ARGS
      #    xmlDoc : The file path of the xml document to parse
      # RETURNS
      #    A list of new PeakList1D objects built from the contents of xmlDoc
      def parsePL(xmlDoc)
        @doc = Nokogiri::XML::Document.parse(File.open(xmlDoc))

        ls = []
        hs = []
        @doc.css("PeakList1D").each do |l_node|
          h = l_node.at_css("PeakList1DHeader")
          c = h.at_css("@creator")
          d = h.at_css("@date")
          x = h.at_css("@expNo")
          n = h.at_css("@name")
          o = h.at_css("@owner")
          p = h.at_css("@procNo")
          s = h.at_css("@source")
          dets = h.at_css("PeakPickDetails")
          dets = parseDetails(dets)
          h = PeakList1DHeader.new(c, d, x, n, o, p, s, dets)

          ps = l_node.css("Peak1D").to_a
          ps.map!{|p| Peak1D.new(p.at_css("@F1"), p.at_css("@intensity"), p.at_css("@type"))}
          ls << PeakList1D.new(h, ps)
        end

        return ls
      end
    end
  end

  # Wrapper around a list of peaks and their accompanying header
  class PeakList1D
    attr_accessor :header, :peaks
     def initialize(header, peaks)
       @header = header
       @peaks = peaks
     end
  end

  # Wrapper around a peak list's header
  class PeakList1DHeader
    attr_accessor :creator, :date, :expNo, :name, :owner, :procNo, :source, :details

    def initialize(creator, date, expNo, name, owner, procNo, source, details)
      @creator = creator.value.to_s
      @date = DateTime.strptime(date, "%Y-%m-%dT%H:%M:%S")
      @expNo = expNo.value.to_i
      @name = name.value.to_s
      @owner = owner.value.to_s
      @procNo = procNo.value.to_i
      @source = source.value.to_s
      @details = details
    end
  end

  # Wrapper around the parameters for peak selection
  class PeakPickDetails
    attr_accessor :f1, :f2, :MI, :MAXI, :PC

    def initialize(f1, f2, mi, maxi, pc)
      @F1 = f1.to_f
      @F2 = f2.to_f
      @MI = mi.to_f
      @MAXI = maxi.to_f
      @PC = pc.to_f
    end
  end

  # Wrapper around individual peak data
  class Peak1D
    attr_accessor :f1, :intensity, :type

    def initialize(f1, intensity, type)
      @f1 = f1.value.to_f
      @intensity = intensity.value.to_f
      @type = type.value.to_i
    end
  end
end

ls = Bruker::XML::PLParser.new.parsePL(ARGV[0])
puts ls
