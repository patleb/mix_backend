class TaskMailer < MainMailer
  def notify
    @message = params[:message]
    mail to: params[:email], template_path: 'task_mailer'
  end
end
