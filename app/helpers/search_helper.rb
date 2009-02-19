module SearchHelper
  
  def anatomy_mockup_data
    return {
      "term" => {"id" => "TAO:12345", "name" => "basihyal bone"},
      "attributes" => [
        {"id" => "PATO:12345", 
          "name" => "shape", 
          "values" => [ 
              {"id" => "PATO:12345", "name" => "serrated"}, 
              {"id" => "PATO:12345", "name" => "pointy"}, 
              {"id" => "PATO:12345", "name" => "round"} 
          ],
          "taxon_annotations" => {"taxon_count" => 25, "annotation_count" => 43},
          "gene_annotations" => {"gene_count" => 3, "annotation_count" => 5}
        },
        {"id" => "PATO:12345", 
          "name" => "color", 
          "values" => [ 
              {"id" => "PATO:12345", "name" => "green"}, 
              {"id" => "PATO:12345", "name" => "blue"}, 
              {"id" => "PATO:12345", "name" => "yellow"} 
          ],
          "taxon_annotations" => {"taxon_count" => 101, "annotation_count" => 321},
          "gene_annotations" => {"gene_count" => 7, "annotation_count" => 13}
        },
        {"id" => "PATO:12345", 
          "name" => "texture", 
          "values" => [ 
              {"id" => "PATO:12345", "name" => "smooth"}, 
              {"id" => "PATO:12345", "name" => "rough"}
          ],
          "taxon_annotations" => {"taxon_count" => 25, "annotation_count" => 43},
          "gene_annotations" => {"gene_count" => 0, "annotation_count" => 0}
        }
      ]
    }
  end
  
  def gene_mockup_data
    return {
      "gene" => {"id" => "ZFIN:ZDB-GENE-990712-18", "name" => "eya1"},
      "phenotypes" => [
        {
          "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
          "attribute" => {"id" => "PATO:12345", "name" => "shape"}, 
          "values" => [ 
              {"id" => "PATO:12345", "name" => "serrated"}, 
              {"id" => "PATO:12345", "name" => "pointy"}, 
              {"id" => "PATO:12345", "name" => "round"} 
          ],
          "related_genes" => [
              {"id" => "ZFIN:ZDB-GENE-990712-18", "name" => "eya2"},
              {"id" => "ZFIN:ZDB-GENE-990712-18", "name" => "eya3"}
          ],
          "related_taxa" => [
              {"id" => "TTO:222222", "name" => "Ictalurus punctatus"},
              {"id" => "TTO:222222", "name" => "Danio rerio"}
          ]
        },
        {
          "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
          "attribute" => {"id" => "PATO:12345", "name" => "shape"}, 
          "values" => [ 
              {"id" => "PATO:12345", "name" => "serrated"}, 
              {"id" => "PATO:12345", "name" => "pointy"}, 
              {"id" => "PATO:12345", "name" => "round"} 
          ],
          "related_genes" => [
              {"id" => "ZFIN:ZDB-GENE-990712-18", "name" => "eya2"},
              {"id" => "ZFIN:ZDB-GENE-990712-18", "name" => "eya3"}
          ],
          "related_taxa" => [
              {"id" => "TTO:222222", "name" => "Ictalurus punctatus"},
              {"id" => "TTO:222222", "name" => "Danio rerio"}
          ]
        },
        {
          "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
          "attribute" => {"id" => "PATO:12345", "name" => "shape"}, 
          "values" => [ 
              {"id" => "PATO:12345", "name" => "serrated"}, 
              {"id" => "PATO:12345", "name" => "pointy"}, 
              {"id" => "PATO:12345", "name" => "round"} 
          ],
          "related_genes" => [
              {"id" => "ZFIN:ZDB-GENE-990712-18", "name" => "eya2"},
              {"id" => "ZFIN:ZDB-GENE-990712-18", "name" => "eya3"}
          ],
          "related_taxa" => [
              {"id" => "TTO:222222", "name" => "Ictalurus punctatus"},
              {"id" => "TTO:222222", "name" => "Danio rerio"},
              {"id" => "TTO:222222", "name" => "Ictalurus punctatus"},
              {"id" => "TTO:222222", "name" => "Ictalurus punctatus"},
              {"id" => "TTO:222222", "name" => "Ictalurus punctatus"},
              {"id" => "TTO:222222", "name" => "Ictalurus punctatus"},
              {"id" => "TTO:222222", "name" => "Ictalurus punctatus"},
              {"id" => "TTO:222222", "name" => "Ictalurus punctatus"},
              {"id" => "TTO:222222", "name" => "Ictalurus punctatus"}
          ]
        }
      ]
    }
  end
  
  def taxon_mockup_data
    return {
      "term" => {
        "id" => "TTO:101020",
        "name" => "Ictalurus",
        "synonyms" => ["Elliops", "Haustor", "Istlarius", "Synechoglanis", "Villarius"]
        },
      "phenotypes" => [
          {
            "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
            "quality" => {"id" => "PATO:12345", "name" => "shape"},
            "taxon_annotations" => {"taxon_count" => 25, "annotation_count" => 43},
            "gene_annotations" => {"gene_count" => 4, "annotation_count" => 4}
          },
          {
            "entity" => {"id" => "TAO:12345", "name" => "dorsal fin"},
            "quality" => {"id" => "PATO:12345", "name" => "shape"},
            "taxon_annotations" => {"taxon_count" => 25, "annotation_count" => 43},
            "gene_annotations" => {"gene_count" => 0, "annotation_count" => 0}
          },
          {
            "entity" => {"id" => "TAO:12345", "name" => "lateral line"},
            "quality" => {"id" => "PATO:12345", "name" => "color"},
            "taxon_annotations" => {"taxon_count" => 25, "annotation_count" => 43},
            "gene_annotations" => {"gene_count" => 0, "annotation_count" => 0}
          }
        ]
    }
  end
  
  def taxon_phenotypes_mockup_data
    return { #characters and all taxa["value-list"] must be the same length
      "characters" => [
          {
            "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
            "quality" => {"id" => "PATO:12345", "name" => "shape"}
          }
        ],
      "taxa" => [
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus punctatus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "serrated"}]
              ]
        },
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus furcatus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "serrated"}]
              ]
        },
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus lupus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "serrated"}]
              ]
        }
        ]
    }
  end
  
  def taxon_phenotypes_mockup_data_multiple
    return { #characters and all taxa["value-list"] must be the same length
      "included_taxa" => [{"id" => "TTO:101020", "name" => "Ictalurus"}],
      "included_characters" => [
        {
          "entity" => {"id" => "TAO:12345", "name" => "bone"},
          "quality" => {"id" => "PATO:12345", "name" => "shape"}
        },
        {
          "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
          "quality" => {"id" => "PATO:12345", "name" => "color"}
        }
        ],
      "characters" => [
          {
            "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
            "quality" => {"id" => "PATO:12345", "name" => "shape"}
          },
          {
            "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
            "quality" => {"id" => "PATO:12345", "name" => "color"}
          },
          {
            "entity" => {"id" => "TAO:12345", "name" => "ceratohyal bone"},
            "quality" => {"id" => "PATO:12345", "name" => "shape"}
          }
        ],
      "taxa" => [
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus punctatus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "serrated"}],
              [{"id" => "PATO:12345", "name" => "serrated"}],
              [{"id" => "PATO:12345", "name" => "serrated"}]
              ]
        },
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus furcatus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "yellow"}, {"id" => "PATO:12345", "name" => "green"}],
              [{"id" => "PATO:12345", "name" => "yellow"}],
              [{"id" => "PATO:12345", "name" => "blue"}]
              ]
        },
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus lupus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "serrated"}],
              [{"id" => "PATO:12345", "name" => "serrated"}],
              [{"id" => "PATO:12345", "name" => "serrated"}]
              ]
        }
        ]
    }
  end
  
  def truncate_list(list, length)
    if list.length <= length
      return list.join(", ")
    else
      list[0..(length - 1)].join(", ") + (" ...and %d more" % (list.length - length))
    end
  end
  
end
