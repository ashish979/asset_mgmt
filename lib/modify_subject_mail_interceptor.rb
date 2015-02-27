class ModifySubjectMailInterceptor
  def self.delivering_email(message)
    #we moved env check here because we could add default from email here too, which need us in production mode too.
    #keeping it in intializer will not register it for production.
    message.subject.prepend("[#{Rails.env}]") unless Rails.env.production?
  end  
end  
