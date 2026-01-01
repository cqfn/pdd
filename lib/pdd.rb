# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'nokogiri'
require 'logger'
require 'time'
require 'rainbow'
require_relative 'pdd/version'
require_relative 'pdd/rule/estimates'
require_relative 'pdd/rule/text'
require_relative 'pdd/rule/duplicates'
require_relative 'pdd/rule/roles'

# PDD main module.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2026 Yegor Bugayenko
# License:: MIT
module PDD
  # If it breaks.
  class Error < StandardError
  end

  # If it violates XSD schema.
  class SchemaError < Error
  end

  RULES = {
    'min-estimate' => PDD::Rule::Estimate::Min,
    'max-estimate' => PDD::Rule::Estimate::Max,
    'min-words' => PDD::Rule::Text::MinWords,
    'max-duplicates' => PDD::Rule::MaxDuplicates,
    'available-roles' => PDD::Rule::Roles::Available
  }.freeze

  # Get logger.
  def self.log
    unless defined?(@logger)
      @logger = Logger.new($stdout)
      @logger.formatter = proc { |severity, _, _, msg|
        case severity
        when 'ERROR'
          "#{Rainbow(severity).red}: #{msg}\n"
        when 'WARN'
          "#{Rainbow(severity).orange}: #{msg}\n"
        else
          "#{msg}\n"
        end
      }
      @logger.level = Logger::WARN
    end
    @logger
  end

  class << self
    attr_writer :logger
    attr_accessor :opts
  end

  # Code base abstraction
  class Base
    # Ctor.
    # +opts+:: Options
    def initialize(opts)
      @opts = opts
      PDD.opts = opts
      PDD.log.level = Logger::INFO if @opts[:verbose]
      PDD.log.level = Logger::ERROR if @opts[:quiet]
      PDD.log.info "My version is #{PDD::VERSION}"
      PDD.log.info "Ruby version is #{RUBY_VERSION} at #{RUBY_PLATFORM}"
    end

    # Generate XML.
    def xml
      dir = @opts[:source] || Dir.pwd
      PDD.log.info "Reading from root dir #{dir}"
      require_relative 'pdd/sources'
      sources = Sources.new(File.expand_path(dir))
      sources.exclude((@opts[:exclude] || []) + (@opts['skip-gitignore'] || []))
      sources.include(@opts[:include])
      sanitize(
        rules(
          Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml << "<?xml-stylesheet type='text/xsl' href='#{xsl}'?>"
            xml.puzzles(attrs) do
              sources.fetch.each do |source|
                source.puzzles.each do |puzzle|
                  PDD.log.info "Puzzle #{puzzle.props[:id]} " \
                               "#{puzzle.props[:estimate]}/#{puzzle.props[:role]} " \
                               "at #{puzzle.props[:file]}"
                  render puzzle, xml
                end
              end
            end
          end.to_xml
        )
      )
    end

    private

    def attrs
      {
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:noNamespaceSchemaLocation' => "#{host('xsd')}/#{PDD::VERSION}.xsd",
        'version' => PDD::VERSION,
        'date' => Time.now.utc.iso8601
      }
    end

    def host(suffix)
      "http://pdd-#{suffix}.teamed.io"
    end

    def xsl
      "#{host('xsl')}/#{PDD::VERSION}.xsl"
    end

    def render(puzzle, xml)
      props = puzzle.props
      xml.puzzle do
        props.map do |k, v|
          xml.send(:"#{k}", v)
        end
      end
    end

    def rules(xml)
      doc = Nokogiri::XML(xml)
      total = 0
      list = @opts[:rule] || []
      unless list.none? { |r| r.start_with?('max-duplicates:') }
        raise PDD::Error, 'You can\'t modify max-duplicates, it\'s always 1'
      end

      list.push('max-duplicates:1').map do |r|
        name, value = r.split(':')
        rule = RULES[name]
        raise "Rule '#{name}' doesn't exist" if rule.nil?

        rule.new(doc, value).errors.each do |e|
          PDD.log.error e
          total += 1
        end
      end
      raise PDD::Error, "#{total} errors, see log above" unless total.zero?

      xml
    end

    def sanitize(xml)
      xsd = Nokogiri::XML::Schema(
        File.read(File.join(File.dirname(__FILE__), '../assets/puzzles.xsd'))
      )
      errors = xsd.validate(Nokogiri::XML(xml)).map(&:message)
      errors.each { |e| PDD.log.error e }
      PDD.log.error(xml) unless errors.empty?
      raise SchemaError, errors.join('; ') unless errors.empty?

      xml
    end
  end
end
