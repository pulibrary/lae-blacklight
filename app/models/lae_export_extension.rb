module LaeExportExtension
  def self.extended(document)
    document.will_export_as(:ttl, 'text/turtle')
    document.will_export_as(:jsonld, 'application/ld+json')
    document.will_export_as(:rdf, 'application/rdf+xml')
  end

  PREFIXES ||= {
    dc: RDF::DC.to_uri,
    dctype: RDF::URI.new('http://purl.org/dc/dcmitype/'),
    foaf: RDF::FOAF.to_uri,
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
  }

  def export_as_ttl
    self['ttl']
  end

  def export_as_jsonld
    self['manifest']
  end

  def export_as_rdf
    graph = RDF::Graph.new
    RDF::Reader.for(:ttl).new(self['ttl']) do |reader|
      reader.each_statement { |statement| graph << statement }
    end
    graph.dump(:rdfxml, prefixes: PREFIXES)
  end
end
