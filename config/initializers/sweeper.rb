# Magic fix for nil.controller_name problema
#
# Thanks: http://collectiveidea.lighthouseapp.com/projects/20257/tickets/12-rails-23-active-scaffold-error-in-production-environment


class ActionController::Caching::Sweeper
  def after(controller)
    self.controller = controller
    callback(:after) if controller.perform_caching
    # Clean up, so that the controller can be collected after this request
    self.controller = nil
  end
end

