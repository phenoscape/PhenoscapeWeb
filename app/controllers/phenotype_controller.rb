class PhenotypeController < ApplicationController
  
  def evo
    @value = params[:subject] ? params[:subject] : "It was null"
  end
  
  
  def devo
  end
  
  
end
