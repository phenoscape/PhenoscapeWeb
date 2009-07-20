## FIXME class-level documentation missing
class PhenotypeController < ApplicationController
  
  caches_page :evo
  caches_page :devo
  
  ## FIXME Should have method documentation as to what it does.
  def evo
    formatAnnotationResults("evo")
  end
  
  ## FIXME should think of a better name for the "devo" view - it's
  ## really more the model organism (MOD) source of the data and the
  ## fact that the phenotypes are linked to genotypes that sets this
  ## apart. Maybe evo versus geno?

  ## FIXME Should have method documentation as to what it does.
  def devo
    formatAnnotationResults("devo")
  end
  
  
  def pub
    #TODO
  end
  
   ## FIXME There seem to be a lot of common path prefixes and URL
  ## parameters interspersed throughout the code - should pull these
  ## together into a set of constants.

  ## FIXME Should have method (and parameter!) documentation as to
  ## what it does and how it does it.
  private
  def formatAnnotationResults(type)
    #should check validity of entity and quality terms, and return 404? if one doesn't exist
     entity_response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + params[:entity])
     @entity = JSON.parse(entity_response.body)
     quality_response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + params[:quality])
     @quality = JSON.parse(quality_response.body)
     #response = Net::HTTP.get_response(self.request.host, "/javascripts/dummy_annotation_results.js")
     url = "/OBD-WS/phenotypes?entity=" + params[:entity] + "&quality=" + params[:quality] + "&type=" + type
     url += "&group=root" if type == "evo"
     if params[:subject] != nil
       subject_response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + params[:subject])
       @subject = JSON.parse(subject_response.body)
       url += "&subject=" + params[:subject]
     else
       @subject = nil
     end
     response = Net::HTTP.get_response(self.request.host, url)
     result = JSON.parse(response.body)
     @subjects = result["subjects"]
     if not @subjects.empty?
       @root = @subjects[0]
     else
       @root = nil
     end
  end  
  
end
