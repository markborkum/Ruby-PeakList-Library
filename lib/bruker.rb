require 'date'
require 'nokogiri'

module Bruker
  module XML
    DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%S'.freeze

    # Parses a Nokogiri-unpacked 'PeakList.xml' document
    #
    # @param doc [Nokogiri::XML] an xml document pre-processed by Nokogiri
    # @return [Bruker::XML::Peaklist, nil] a data structure containing the xml data, or nil on failure
    def self.parse(doc)
      return nil if doc.nil?

      doc.xpath('PeakList').collect { |node|
        Bruker::XML::PeakList.parse(node)
      }.first
    end

    # Highest-level data structure representing a 'PeakList.xml' document.
    # => Contains the last-modified datetime as well as a list of individual PeakLists
    class PeakList
      class << self
        # Parses through the xml document from highest to lowest level of abstraction,
        # => then organizes the resulting data structures to mirror the original document
        #
        # @param doc [Nokogiri::XML::Document] the xml document being parsed
        # @return [PeakList, nil] the data structure representation of the peak lists, or nil on failure
        def parse(doc)
          return nil if doc.nil?
          return nil unless doc.name == 'PeakList'

          modified = if !(attribute = doc.attribute('modified')).nil?
            DateTime.strptime(attribute.value.to_s, Bruker::XML::DATETIME_FORMAT)
          else
            nil
          end

          children = doc.xpath('PeakList1D').collect { |node|
            Bruker::XML::PeakList1D.parse(node)
          }

          new(modified, children)
        end
      end

      attr_accessor :modified, :children
      # PeakList constructor
      #
      # @param modified [DateTime] the last date and time the document was modified
      # @param children [[PeakList1D]] a list of 1-dimensional peak lists associated with the document
      def initialize(modified, children = [])
        @modified = modified
        @children = children
      end

      # Converts the PeakList object, as well as all its children, to xml representations
      #
      # @return [Nokogiri::XML::Document] a new xml document containing the PeakList's data
      def to_xml
        # TODO Auto-generated method stub
        @n_doc = Nokogiri::XML::Document.new
        n_root =(Nokogiri::XML::Node.new("PeakList", @n_doc))
        n_root.set_attribute("modified", @modified.to_s)
        @n_doc.root=(n_root)
        children.collect { |child|
          @n_doc.root() << (child.to_xml(@n_doc))
        }
        return @n_doc
      end
    end

    # Data structure representing a single header and a list of 1-dimensional peaks
    class PeakList1D
      class << self
        # Parses through the PeakList's xml header and peaks,
        # => then converts them to corresponding data structures and
        # => organizes them according to their original structure
        # @param doc [Nokogiri::XML::Document] the Nokogiri document being parsed
        # @return [PeakList1D, nil] the data structure representation of the
        # => peak list and its children, or nil on failure
        def parse(doc)
          return nil if doc.nil?
          return nil unless doc.name == 'PeakList1D'

          header = doc.xpath('PeakList1DHeader').collect { |node|
            Bruker::XML::PeakList1DHeader.parse(node)
          }.first

          children = doc.xpath('Peak1D').collect { |node|
            Bruker::XML::Peak1D.parse(node)
          }

          new(header, children)
        end
      end

      attr_accessor :header, :children

      # PeakList1D constructor
      #
      # @param header [PeakList1DHeader] the header of the peak list
      # @param children [[Peak1D]] a list of peaks belonging to the peak list
      def initialize(header, children = [])
        @header = header
        @children = children
      end

      # Converts the PeakList, as well as all of its children, to xml representations
      #
      # @param doc [Nokogiri::XML::Document] the document the xml representations will
      # => live under
      # @return [Nokogiri::XML::Node] xml representation of the list and its children
      def to_xml(doc)
        # TODO Auto-generated method stub
        peak_list = Nokogiri::XML::Node.new("PeakList1D", doc)
        peak_list << @header.to_xml(doc)
        children.collect {|child|
          peak_list << child.to_xml(doc)
        }
        return peak_list
      end
    end

    # Data structure representing the header of a 1-dimensional peak list
    class PeakList1DHeader
      class << self
        # Parses through the raw xml of a header and its peak-picking details, converting
        # => them to data structures and preserving their original structure
        #
        # @param doc [Nokogiri::XML::Document] the xml document being parsed
        # @return [PeakList1DHeader, nil] The data structure repsentation of the
        # => header and picking details, or nil on failure
        def parse(doc)
          return nil if doc.nil?
          return nil unless doc.name == 'PeakList1DHeader'

          creator = if !(attribute = doc.attribute('creator')).nil?
            attribute.value.to_s
          else
            nil
          end

          date = if !(attribute = doc.attribute('date')).nil?
            DateTime.strptime(attribute.value.to_s, Bruker::XML::DATETIME_FORMAT)
          else
            nil
          end

          expNo = if !(attribute = doc.attribute('expNo')).nil?
            attribute.value.to_i
          else
            nil
          end

          name = if !(attribute = doc.attribute('name')).nil?
            attribute.value.to_s
          else
            nil
          end

          owner = if !(attribute = doc.attribute('owner')).nil?
            attribute.value.to_s
          else
            nil
          end

          procNo = if !(attribute = doc.attribute('procNo')).nil?
            attribute.value.to_i
          else
            nil
          end

          source = if !(attribute = doc.attribute('source')).nil?
            attribute.value.to_s
          else
            nil
          end

          details = doc.xpath('PeakPickDetails').collect { |node|
            Bruker::XML::PeakPickDetails.parse(node)
          }.first

          new(creator, date, expNo, name, owner, procNo, source, details)
        end
      end

      attr_accessor :creator, :date, :expNo, :name, :owner, :procNo, :source, :details

      # Peak list header constructor
      #
      # @param creator [String]
      # @param date [DateTime]
      # @param expNo [Integer]
      # @param name [String]
      # @param owner [String]
      # @param procNo [Integer]
      # @param source [String]
      # @param details [PeakPickDetails]
      def initialize(creator, date, expNo, name, owner, procNo, source, details)
        @creator = creator
        @date = date
        @expNo = expNo
        @name = name
        @owner = owner
        @procNo = procNo
        @source = source
        @details = details
      end

      # Converts the peak list header, as well as its picking details, to xml representations
      #
      # @param doc [Nokogiri::XML::Document] the document the new nodes will live under
      # @return [Nokogiri::XML::Node] the xml representation of the header and its details
      def to_xml(doc)
        # TODO Auto-generated method stub
        header = Nokogiri::XML::Node.new("PeakList1DHeader", doc)
        header.set_attribute("creator", @creator)
        header.set_attribute("date", @date.to_s)
        header.set_attribute("expNo", @expNo.to_s)
        header.set_attribute("name", @name)
        header.set_attribute("owner", @owner)
        header.set_attribute("procNo", @procNo.to_s)
        header.set_attribute("source", @source)
        header << @details.to_xml(doc)
        return header
      end
    end

    # The peak-picking details of a peak list header
    class PeakPickDetails
      CONTENT_REGEXP = Regexp.new('^\s*F1=(.+)ppm,\s*F2=(.+)ppm,\s*MI=(.+)cm,\s*MAXI=(.+)cm,\s*PC=(.+)\s*$').freeze

      class << self
        # Parses through the picking details and constructs a data structure
        # => representation for them
        # @param doc [Nokogiri::XML::Document] the xml document being parsed
        # @returns [PeakPickDetails, nil] the data structure representation of
        # => the details, or nil on failure
        def parse(doc)
          return nil if doc.nil?
          return nil unless doc.name == 'PeakPickDetails'

          if !(md = CONTENT_REGEXP.match(doc.content.strip)).nil?
            new(md[1].to_f, md[2].to_f, md[3].to_f, md[4].to_f, md[5].to_f)
          else
            nil
          end
        end
      end

      attr_accessor :F1, :F2, :MI, :MAXI, :PC

      # PeakPickDetails constructor
      #
      # @param _F1 [Float]
      # @param _F2 [Float]
      # @param _MI [Float]
      # @param _MAXI [Float]
      # @param _PC [Float]
      def initialize(_F1, _F2, _MI, _MAXI, _PC)
        @F1 = _F1
        @F2 = _F2
        @MI = _MI
        @MAXI = _MAXI
        @PC = _PC
      end

      # Converts the peak-picking details into an xml representation
      #
      # @param doc [Nokogiri::XML::Document] the xml document the new nodes will
      # => live under
      # @return [Nokogiri::XML::Node] the xml representation of the peak-picking details
      def to_xml(doc)
        # TODO Auto-generated method stub
        details = Nokogiri::XML::Node.new("PeakPickDetails", doc)
        details.content=("F1=#{@F1.to_s}ppm, F2=#{@F2.to_s}ppm, MI=#{@MI.to_s}cm, MAXI=#{@MAXI.to_s}cm, PC=#{@PC.to_s}")
        return details
      end
    end

    # Data structure representation of a 1-dimensional peak
    class Peak1D
      class << self
        # Parses the peak and converts it to a 'Peak1D' object
        #
        # @param doc [Nokogiri::XML::Document] the xml document being parsed
        # @return [Peak1D, nil] the data structure representation of the peak,
        # => or nil on failure
        def parse(doc)
          return nil if doc.nil?
          return nil unless doc.name == 'Peak1D'

          _F1 = if !(attribute = doc.attribute('F1')).nil?
            attribute.value.to_f
          else
            nil
          end

          intensity = if !(attribute = doc.attribute('intensity')).nil?
            attribute.value.to_f
          else
            nil
          end

          type = if !(attribute = doc.attribute('type')).nil?
            attribute.value.to_i
          else
            nil
          end

          new(_F1, intensity, type)
        end
      end

      attr_accessor :F1, :intensity, :type

      # 1-dimensional peak constructor
      #
      # @param _F1 [Float]
      # @param intensity [Float]
      # @param type [Integer]
      def initialize(_F1, intensity, type)
        @F1 = _F1
        @intensity = intensity
        @type = type
      end

      # Returns an xml representation of the peak
      #
      # @param doc [Nokogiri::XML::Document] the xml document the peak will live under
      # @return [Nokogiri::XML::Node] the xml representation of the peak
      def to_xml(doc)
        # TODO Auto-generated method stub
        peak = Nokogiri::XML::Node.new("Peak1D", doc)
        peak.set_attribute("F1", @F1.to_s)
        peak.set_attribute("intensity", @intensity.to_s)
        peak.set_attribute("type", @type.to_s)
        return peak
      end
    end
  end
end
