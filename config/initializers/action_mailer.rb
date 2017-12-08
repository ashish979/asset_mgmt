require './lib/modify_subject_mail_interceptor'
ActionMailer::Base.register_interceptor(ModifySubjectMailInterceptor)