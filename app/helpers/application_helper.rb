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

  def profiles_edit?
    params[:controller] == 'profiles' && params[:action] == 'edit'
  end

  def profiles_privacy?
    params[:controller] == 'profiles' && params[:action] == 'edit_privacy'
  end

  def orders?
    params[:controller] == 'orders'
  end

  def home?
    params[:controller] == 'home'
  end

  def events?
    params[:controller] == 'events'
  end

  def offers?
    params[:controller] == 'offers'
  end

  def gives?
    params[:controller] == 'gives'
  end

  def event_image(promotion,format=:normal)
    photo = promotion.carousel_image unless format == :normal
    photo = promotion.normal_image unless format == :carousel
    if photo.blank?
      temp = (format == :thumb) ? 'aff-user-small.png':'aff-user-large.png'
      img = temp
    else
      temp = (format == :normal) ? :medium : :carousel
     img = photo.image.url(temp)
    end
    image_tag img
  end

  def event_description(description,length=130)
    #description[0..length] unless description.nil?
    truncate(description, :length => length)
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

  def account_settings_menu_clicked
    temp = session['menu_link']
    session['menu_link'] = nil

    menu = ['profile info', 'billing info', 'notifications', 'change password']
    temp =  menu.index(temp)
    temp.nil? ? 1 : temp + 1
  end

  def event_date_time_format(event,format='date')
    return "" if event.date.blank?
    return global_date_format(event.date) if format=='date'
    return (event.date.strftime("%l:%M %p") unless event.date.blank?) if format=='time'
  end

  def ary_to_arys(ary, split_size)
    temp=[]
    ary.size.times do |x|
      if (x%split_size == 0)
        temp << ary[x, split_size]
      end
    end
    temp
  end

  def global_date_format(date)
    return "" if date.blank?
    date.strftime("%b %d, %Y")
  end

  def global_time_format(date)
    return "" if date.blank?
    date.strftime("%l:%M %p")
  end

  def user_email_notifications(status)
    status ? "ON" : "OFF"
  end


  def unread_messages_count
    session[:unread_messages_count] || 0
  end

  def offer_activation_link(user,offer)
    (user.plan == 'free' ? '#billing_info' : activate_offer_path(offer.id))
  end

  def message_with_links_and_paragraphs(body)
    formated_paragraphs = []
    body.split("\n").each do |paragraph|
        x = []
        #unless paragraph.empty?
          paragraph.split(" ").each do |word|
            if (word =~ URI::regexp).nil?
              x << word
            else
              x << "<a href="+word+">"+word+"</a>"
            end
          end
          formated_paragraphs << "<p>" + x.join(" ") + "</p>"
        #end
    end
    return formated_paragraphs.join
  end

end
 
 