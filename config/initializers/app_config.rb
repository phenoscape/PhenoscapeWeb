#Constants
SOURCE_KEYS = {
  'zfin_gene'           => :gene, 
  'teleost-taxonomy'    => :taxon,
  'teleost_anatomy'     => :entity,
  'vertebrate_anatomy'  => :entity,
  'caro'                => :entity,
  'gene_ontology'       => :entity,
  'biological_process'  => :entity,
  'molecular_function'  => :entity,
  'cellular_component'  => :entity,
  'quality'             => :quality,
  'phenoscape_pub'      => :publication,
  'zfin_pub'            => :zfin_publication,
  'museum'              => :collection
}


SUBJECT_RELATION_MAPPINGS = {
  "OBO_REL:is_a"          => "is a type of",
  "OBO_REL:part_of"       => "is part of",
  "part_of"               => "is part of",
  "OBO_REL:develops_from" => "develops from",
  "develops_from"         => "develops from",
  "overlaps"              => "overlaps",
  "correlates_with"       => "correlates with",
  "increased_in_magnitude_relative_to" => "increased in magnitude relative to",
  "decreased_in_magnitude_relative_to" => "decreased in magnitude relative to",
  "similar_in_magnitude_relative_to"   => "similar in magnitude relative to",
  "reciprocal_of"         => "reciprocal of",
  "OBO_REL:has_part"      => "has part",
  "has_quality"           => "has quality"
}


OBJECT_RELATION_MAPPINGS = {
  "OBO_REL:is_a"          => "has subtype",
  "OBO_REL:part_of"       => "may have part",
  "part_of"               => "may have part",
  "OBO_REL:develops_from" => "develops into",
  "develops_from"         => "develops into",
  "overlaps"              => "overlaps",
  "correlates_with"       => "correlates with",
  "reciprocal_of"         => "has reciprocal",
  "OBO_REL:has_part"      => "may be part of",
  "has_quality"           => "may be quality of"
}


POSTCOMPOSTION_RELATION_MAPPINGS = {
  "OBO_REL:connected_to"               => "on",
  "connected_to"                       => "on",
  "anterior_to"                        => "anterior to",
  "BSPO:0000096"                       => "anterior to",
  "posterior_to"                       => "posterior to",
  "BSPO:0000099"                       => "posterior to",
  "adjacent_to"                        => "adjacent to",
  "OBO_REL:adjacent_to"                => "adjacent to",
  "increased_in_magnitude_relative_to" => "increased in magnitude relative to",
  "decreased_in_magnitude_relative_to" => "decreased in magnitude relative to",
  "similar_in_magnitude_relative_to"   => "similar in magnitude relative to",
  "PHENOSCAPE:complement_of"           => "not"
}