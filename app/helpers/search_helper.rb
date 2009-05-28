module SearchHelper
  
  def anatomy_mockup_data
    return {
      "term" => {"id" => "TAO:12345", "name" => "bone"},
      "attributes" => [
        {"id" => "PATO:12345", 
          "name" => "count in organism", 
          "values" => [ 
              {"id" => "PATO:12345", "name" => "absent from organism"}, 
              {"id" => "PATO:12345", "name" => "present in normal numbers in organism"}
          ],
          "taxon_annotations" => {"taxon_count" => 4, "annotation_count" => 4},
          "gene_annotations" => {"gene_count" => 3, "annotation_count" => 5}
        },
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
      "gene" => {"id" => "ZFIN:ZDB-GENE-040426-731", "name" => "brpf1"},
      "phenotypes" => [
        {
          "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
          "attribute" => {"id" => "PATO:12345", "name" => "count in organism"}, 
          "values" => [ 
              {"id" => "PATO:12345", "name" => "absent from organism"}, 
              {"id" => "PATO:12345", "name" => "present in organism"}
          ],
          "related_genes" => [
          ],
          "related_taxa" => [
              {
                 "id" => "TTO:101020",
                  "name" => "Ictalurus punctatus"
              },
              {
                 "id" => "TTO:101020",
                  "name" => "Ictalurus furcatus"
              },
              {
                 "id" => "TTO:101020",
                  "name" => "Ictalurus lupus"
              },
              {
                 "id" => "TTO:101020",
                  "name" => "Astyanax validus"
              }
          ]
        },
        {
          "entity" => {"id" => "TAO:12345", "name" => "ceratohyal bone"},
          "attribute" => {"id" => "PATO:12345", "name" => "shape"}, 
          "values" => [ 
              {"id" => "PATO:12345", "name" => "abnormal"}, 
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
          "entity" => {"id" => "TAO:12345", "name" => "opercle"},
          "attribute" => {"id" => "PATO:12345", "name" => "size"}, 
          "values" => [ 
              {"id" => "PATO:12345", "name" => "decreased size"}, 
              {"id" => "PATO:12345", "name" => "increased width"}, 
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
            "quality" => {"id" => "PATO:12345", "name" => "count in organism"},
            "taxon_annotations" => {"taxon_count" => 3, "annotation_count" => 1},
            "gene_annotations" => {"gene_count" => 1, "annotation_count" => 2}
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
      "included_taxa" => [],
      "included_characters" => [
        {
          "entity" => {"id" => "TAO:12345", "name" => "bone"},
          "quality" => {"id" => "PATO:12345", "name" => "count in organism"}
        }
        ],
      "characters" => [
          {
            "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
            "quality" => {"id" => "PATO:12345", "name" => "count in organism"}
          },
          {
            "entity" => {"id" => "TAO:12345", "name" => "opercle"},
            "quality" => {"id" => "PATO:12345", "name" => "count in organism"}
          }
        ],
      "taxa" => [
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus punctatus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "absent from organism"}],
              []
              ]
        },
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus furcatus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "absent from organism"}],
              []
              ]
        },
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus lupus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "absent from organism"}],
              []
              ]
        },
        {
           "id" => "TTO:101020",
            "name" => "Astyanax validus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "present in organism"}],
              [{"id" => "PATO:12345", "name" => "present in organism"}]
              ]
        }
        ]
    }
  end
  
  def taxon_phenotypes_mockup_data_ictalurus
    return { #characters and all taxa["value-list"] must be the same length
      "included_taxa" => [],
      "included_characters" => [
        {
          "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
          "quality" => {"id" => "PATO:12345", "name" => "count in organism"}
        }
        ],
      "characters" => [
          {
            "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
            "quality" => {"id" => "PATO:12345", "name" => "count in organism"}
          }
        ],
      "taxa" => [
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus punctatus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "absent from organism"}]
              ]
        },
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus furcatus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "absent from organism"}]
              ]
        },
        {
           "id" => "TTO:101020",
            "name" => "Ictalurus lupus",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "absent from organism"}]
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
  
  def genes_phenotypes_mockup_data
    return { #characters and all taxa["value-list"] must be the same length
      "included_genes" => [],
      "included_characters" => [
        {
          "entity" => {"id" => "TAO:12345", "name" => "bone"},
          "quality" => {"id" => "PATO:12345", "name" => "count in organism"}
        }
        ],
      "characters" => [
           {
              "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
              "quality" => {"id" => "PATO:12345", "name" => "count in organism"}
            },
            {
              "entity" => {"id" => "TAO:12345", "name" => "epibranchial bone"},
              "quality" => {"id" => "PATO:12345", "name" => "count in organism"}
            }
        ],
      "genes" => [
        {
           "id" => "ZFIN:101020",
            "name" => "brpf1",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "present in normal numbers in organism"}, {"id" => "PATO:12345", "name" => "absent from organism"}],
              []
              ]
        },
        {
           "id" => "ZFIN:101020",
            "name" => "trpm7",
            "value-list" => [
              [],
              [{"id" => "PATO:12345", "name" => "count in organism [3 count]"}]
              ]
        }
        ]
    }
  end
  
  def genes_phenotypes_mockup_data_brpf1
    return { #characters and all taxa["value-list"] must be the same length
      "included_genes" => [],
      "included_characters" => [
        {
          "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
          "quality" => {"id" => "PATO:12345", "name" => "count in organism"}
        }
        ],
      "characters" => [
           {
              "entity" => {"id" => "TAO:12345", "name" => "basihyal bone"},
              "quality" => {"id" => "PATO:12345", "name" => "count in organism"}
            }
        ],
      "genes" => [
        {
           "id" => "ZFIN:101020",
            "name" => "brpf1",
            "value-list" => [
              [{"id" => "PATO:12345", "name" => "present in normal numbers in organism"}, {"id" => "PATO:12345", "name" => "absent from organism"}]
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
  
  #list is a sample of the total number given in length
  #length parameter of zero always just leaves off the "n more"
  def list_more(list, length)
    if list.empty?
      return "<i>None</i>"
    elsif length > list.length
      return list.join(", ") + " and " + (length - list.length).to_s + " more"
    else
      return list.join(", ")
    end
  end
  
  # should this method sanitize input text before returning?
  def format_homologies(list)
    list.collect do |item|
      target = item["target"]
      entity_id = target["entity"]["id"]
      entity_name = target["entity"]["name"]
      taxon_id = target["taxon"]["id"]
      taxon_name = format_taxon(target["taxon"]["name"])
      %Q'<a href="/search/anatomy/#{entity_id}" title="#{entity_id}">#{entity_name}</a> in <a href="/search/taxon/#{taxon_id}" title="#{taxon_id}">#{taxon_name}</a>'
		end
  end
  
end
