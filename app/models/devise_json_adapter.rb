module DeviseJsonAdapter
  protected

  # Handle JSON registration errors.
  #
  def render_with_scope(action, options={})
    respond_to do |format|
      format.html { super }
      format.json do
        if resource.errors
          render_json_errors(resource, resource_name)
        end
      end
    end
  end

  # Since XMLHttpRequest can't see redirects, we replace redirects with a JSON
  # response of {redirect: url}.
  #
  def redirect_to(*args)
    respond_to do |format|
      format.html { super }
      format.json do
        render :status => 200, :json => {:tr_data => '123213213213'}
        #render :json => {:redirect => stored_location_for(resource_name) || after_sign_in_path_for(resource)}
      end
    end
  end

  # Convert ActiveModel errors into JSON so they can be rendered client-side.
  # Result is {errors: {'name': 'message', ...}} which is suitable for passing to
  # jQuery.validate's formErrors method.
  #
  def render_json_errors(model, model_name = nil)
    model_name ||= model.class.name.underscore
    
    # Map the error keys into standard HTML element names (e.g., :password -> 'user[password]')
    form_errors = Hash[model.errors.collect { |attr, msg| ["#{model_name}[#{attr}]", msg] }]
    
    render :status => :unprocessable_entity, :json => {:errors => form_errors}
  end
end
