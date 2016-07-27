require 'date'
require 'nokogiri'

module Bruker
  module XML
    DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%S'.freeze

    def self.parse(doc)
      return nil if doc.nil?
      
      doc.xpath('PeakList').collect { |node|
        Bruker::XML::PeakList.parse(node)
      }.first
    end

    class PeakList
      class << self
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
      
      def initialize(modified, children = [])
        @modified = modified
        @children = children
      end
      
      def to_xml
        # TODO Auto-generated method stub
        nil
      end
    end

    class PeakList1D
      class << self
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
      
      def initialize(header, children = [])
        @header = header
        @children = children
      end
      
      def to_xml
        # TODO Auto-generated method stub
        nil
      end
    end

    class PeakList1DHeader
      class << self
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
          }
          
          new(creator, date, expNo, name, owner, procNo, source, details)
        end
      end
      
      attr_accessor :creator, :date, :expNo, :name, :owner, :procNo, :source, :details
      
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
      
      def to_xml
        # TODO Auto-generated method stub
        nil
      end
    end

    class PeakPickDetails
      CONTENT_REGEXP = Regexp.new('^\s*F1=(.+)ppm,\s*F2=(.+)ppm,\s*MI=(.+)cm,\s*MAXI=(.+)cm,\s*PC=(.+)\s*$').freeze
      
      class << self
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
      
      def initialize(_F1, _F2, _MI, _MAXI, _PC)
        @F1 = _F1
        @F2 = _F2
        @MI = _MI
        @MAXI = _MAXI
        @PC = _PC
      end
      
      def to_xml
        # TODO Auto-generated method stub
        nil
      end
    end

    class Peak1D
      class << self
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
      
      def initialize(_F1, intensity, type)
        @F1 = _F1
        @intensity = intensity
        @type = type
      end
      
      def to_xml
        # TODO Auto-generated method stub
        nil
      end
    end
  end
end
