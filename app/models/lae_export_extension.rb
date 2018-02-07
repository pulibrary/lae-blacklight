# frozen_string_literal: true
module LaeExportExtension
  # Provides Blacklight export extensions for turtle, JSON-LD, and RDF-XML
  # @param document [SolrDocument] the document with extended export media types
  def self.extended(document)
    document.will_export_as(:ttl, 'text/turtle')
    document.will_export_as(:jsonld, 'application/ld+json')
    document.will_export_as(:rdf, 'application/rdf+xml')
  end

  # Prefixes for RDF and JSON-LD namespaces
  PREFIXES ||= {
    dc: RDF::Vocab::DC.to_uri,
    dctype: RDF::URI.new('http://purl.org/dc/dcmitype/'),
    foaf: RDF::Vocab::FOAF.to_uri,
    geonames:  RDF::URI.new('http://sws.geonames.org/'),
    lae: RDF::URI.new('http://lae.princeton.edu/'),
    lang: RDF::URI.new('http://id.loc.gov/vocabulary/iso639-2/'),
    lcco: RDF::URI.new('http://id.loc.gov/vocabulary/countries/'),
    lcga: RDF::URI.new('http://id.loc.gov/vocabulary/geographicAreas/'),
    lcsh: RDF::URI.new('http://id.loc.gov/authorities/subjects/'),
    marcrel: RDF::URI.new('http://id.loc.gov/vocabulary/relators/'),
    owl: RDF::OWL.to_uri,
    pulterms: RDF::URI.new('http://princeton.edu/pulstore/terms/'),
    rdf: RDF.to_uri,
    rdfs: RDF::RDFS.to_uri,
    tgm: RDF::URI.new('http://id.loc.gov/vocabulary/graphicMaterials/'),
    unit: RDF::URI.new('http://sweet.jpl.nasa.gov/2.3/reprSciUnits.owl'),
    xsd: RDF::XSD.to_uri
  }.freeze

  # Exports only the cached Turtle as a View of the Document
  # @return [String] the cached turtle
  def export_as_ttl
    self['ttl']
  end

  # Exports only the cached IIIF Manifest for the JSON-LD View of the Document
  # @return [String] the cached IIIF Manifest
  def export_as_jsonld
    self['manifest']
  end

  # Exports only the cached Turtle transformed into RDF-XML as a View of the Document
  # @return [String] RDF-XML generated from the cached turtle
  def export_as_rdf
    graph = RDF::Graph.new
    RDF::Reader.for(:ttl).new(self['ttl']) do |reader|
      reader.each_statement { |statement| graph << statement }
    end
    graph.dump(:rdfxml, prefixes: PREFIXES)
  end
end
