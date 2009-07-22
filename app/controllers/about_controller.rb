## FIXME missing documentation for class and methods.
class AboutController < ApplicationController
  
  caches_page :index
  caches_page :services
  caches_page :ontology_relationships
  
  def index
    @title = "About"
  end
  
  
  def services
  end
  
  def ontology_relationships
    @title = "Ontology Relationship Info"
  end
  
end
