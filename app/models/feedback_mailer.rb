class FeedbackMailer < ActionMailer::Base
  
  def feedback(feedback)
    @recipients  = 'help@phenoscape.org'
    @from        = 'noreply@phenoscape.org'
    @subject     = "[Feedback for Knowledgebase] #{feedback.subject}"
    @sent_on     = Time.now
    @body[:feedback] = feedback    
  end

end
