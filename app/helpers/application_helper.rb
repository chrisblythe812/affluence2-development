module ApplicationHelper
  class BraintreeFormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::TagHelper

    def initialize(object_name, object, template, options, proc)
      super
      @braintree_params = @options[:params]
      @braintree_errors = @options[:errors]
      @braintree_existing = @options[:existing]
    end

    def fields_for(record_name, *args, &block)
      options = args.extract_options!
      options[:builder] = BraintreeFormBuilder
      options[:params] = @braintree_params && @braintree_params[record_name]
      options[:errors] = @braintree_errors && @braintree_errors.for(record_name)
      new_args = args + [options]
      super record_name, *new_args, &block
    end

    def text_field(method, options = {})
      has_errors = @braintree_errors && @braintree_errors.on(method).any?
      field = super(method, options.merge(:value => determine_value(method)))
      result = content_tag("div", field, :class => has_errors ? "fieldWithErrors" : "")
      result.safe_concat validation_errors(method)
      result
    end

    protected

    def determine_value(method)
      if @braintree_params
        @braintree_params[method]
      elsif @braintree_existing

        if @braintree_existing.kind_of?(Braintree::CreditCard)

          case method
            when :number
              method = :masked_number
            when :cvv
              return nil
          end
        end

        @braintree_existing.send(method)
      else
        nil
      end
    end

    def validation_errors(method)
      if @braintree_errors && @braintree_errors.on(method).any?
        @braintree_errors.on(method).map do |error|
          content_tag("div", ERB::Util.h(error.message), {:style => "color: red;"})
        end.join
      else
        ""
      end
    end
  end

  def profiles?
    params[:controller] == 'profiles'
  end
 
  def display_image(photos, format = :medium)
    if photos.blank?
      temp = (format == :thumb) ? 'aff-user-small.png':'aff-user-large.png'
      image_tag temp
    else
      image_tag photos.first.image.url(format)
    end
  end

  def states_of(country_code)
    begin
      Carmen::states(country_code)
    rescue Carmen::StatesNotSupported, Carmen::NonexistentCountry
      [["No States Available", '']]
    end
  end

  def resource_name
    :user
  end

  def resource
    current_user
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

end
 