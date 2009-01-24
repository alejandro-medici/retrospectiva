class ApplicationController < ActionController::Base
  protect_from_forgery # :secret => '7161d9a625e85aa1d6f2f460327dea4d'
  filter_parameter_logging :password
  
  before_filter :set_locale
  before_filter :authenticate
  before_filter :set_time_zone
  after_filter  :reset_request_cache
  
  helper_method :layout_markers

  class << self
    def verify_action(name, options = {})
      verify options.merge(:only => name)
    end        
    protected :verify_action    
  end

  protected

    # Set locale
    def set_locale
      I18n.locale = RetroCM[:general][:basic][:locale]    
    end

    def set_time_zone
      Time.zone = User.current.time_zone
    end

    def reset_request_cache
      User.current = nil
      Project.current = nil
    end

    def cached_user_attribute(name, fallback = '')
      if User.current.public?
        cookies["__cu_#{name}"] || fallback
      else
        User.current.send(name)
      end
    end

    def cache_user_attributes!(attributes) 
      attributes.each do |name, value|
        cookies["__cu_#{name}"] = { 'value' => value, 'expires' => 6.months.from_now }
      end
    end

    def permit_private_key_access
      if User.current.public? and params[:private].present?
        user = User.find_by_private_key_and_active(params[:private], true)
        if user
          User.current = user
          session[:user_id] = User.current.id
        end
      end || true
    end

    def rescue_action_in_public(exception) #:doc:
      status_code = response_code_for_rescue(exception)
      returning render_optional_error_file(status_code) do
        if status_code == :internal_server_error
          ExceptionNotifier.deliver_exception_notification(exception, self, request, {})
        end
      end      
    end

  private  

    def layout_markers
      @layout_markers ||= {
        :header => RetroCM[:content][:custom][:header].to_s,
        :footer => '',
        :content_styles => ''
      }
    end

    def render_optional_error_file(status_code)
      status = interpret_status(status_code)
      path = "#{RAILS_ROOT}/app/views/rescue/#{status[0,3]}.html.erb" 
      if File.exist?(path)
        render :file => path, :layout => 'application', :status => status
      else
        head status
      end
    end
  
end
