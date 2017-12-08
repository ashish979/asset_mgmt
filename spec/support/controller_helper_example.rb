module ControllerHelper
  def should_authorize(action, subject)
    controller.stub(:authorize!).with(action, subject).and_return(true)
  end
end