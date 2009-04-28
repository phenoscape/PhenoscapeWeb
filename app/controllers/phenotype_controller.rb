class PhenotypeController < ApplicationController
  
  def evo
    formatAnnotationResults("evo")
  end
  
  
  def devo
    formatAnnotationResults("devo")
  end
  
  
  private
  def formatAnnotationResults(type)
    #should check validity of entity and quality terms, and return 404? if one doesn't exist
     entity_response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + params[:entity])
     @entity = ActiveSupport::JSON.decode(entity_response.body)
     quality_response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + params[:quality])
     @quality = ActiveSupport::JSON.decode(quality_response.body)
     #response = Net::HTTP.get_response(self.request.host, "/javascripts/dummy_annotation_results.js")
     url = "/OBD-WS/phenotypes?entity=" + params[:entity] + "&quality=" + params[:quality] + "&type=" + type
     if params[:subject] != nil
       subject_response = Net::HTTP.get_response(self.request.host, "/OBD-WS/term/" + params[:subject])
       @subject = ActiveSupport::JSON.decode(subject_response.body)
       logger.info("Adding subject to URL")
       url += "&subject=" + params[:subject]
     else
        @subject = nil
     end
     logger.info("URL is: " + url)
     response = Net::HTTP.get_response(self.request.host, url)
     logger.info("The response was" + response.body)
     result = ActiveSupport::JSON.decode(response.body)
     bySubject = Hash.new {|hash, key| hash[key] = {"subject" => {}, "phenotypes" => []} }
     for item in result["phenotypes"]
       key = item["subject"]["id"]
       bySubject[key]["subject"] = item["subject"]
       bySubject[key]["phenotypes"].push(item)
     end
     @phenotypes = bySubject
  end
  
  
end
