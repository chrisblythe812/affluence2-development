class ApiController < ApplicationController

  skip_before_filter :authenticate_user!

  layout "mobile"
  #todo need to add related styles

  def user_sign_in
    access_grant = AccessGrant.find_access(params["access_token"])
    if access_grant
      render "api/sign_in", :locals => {:callback_url => params["callback_url"]}
    else
      render "api/message", :locals => {:message => "Could not authenticate access token"}
    end
  end

  def authorize_application
    json = ActiveSupport::JSON.decode(request.body)
    if json["key"] && json["secret"]
      if application = ClientApplication.where("application_key = ? AND secret = ?", json["key"], json["secret"]).first
        AccessGrant.prune!
        access_grant = application.access_grants.create
        access_grant.start_expiry_period!
        render :json => {:access_token => access_grant.token, :expires_in => access_grant.access_token_expires_at}.to_json
      else
        render :json => {:code => 401, :message => "Could not authenticate application"}.to_json
      end
    else
      render :json => {:code => 401, :message => "Missing Application Key and/or Secret"}.to_json
    end
  end

  def authorize_user
    params = ActiveSupport::JSON.decode(request.body)
    access_grant = AccessGrant.find_access(params["access_token"])
    if access_grant && access_grant.valid_token?
      user = User.where(:email => params["email"]).first
      if user && user.valid_password?(params["password"])
        user.generate_token
        render :json => {:message => "Success", :user_token => user.token}
      else
        render :json => {:code => 401, :error => "Invalid email and/or password."}.to_json
      end
    else
      render :json => {:code => 401, :error => "Access Token Invalid/Expired"}.to_json
    end
  end


  def validate_tokens
    params = ActiveSupport::JSON.decode(request.body)
    access_grant = AccessGrant.find_access(params["access_token"])
    user = User.where(:token => params["user_token"]).first
    if user && access_grant
      render :json => {:user_token => user.valid_api_token?, :access_token => access_grant.valid_token?}.to_json
    else
      if user.nil? && access_grant.nil?
        render :json => {:message => "Invalid access token and user token"}.to_json, :status => 401
      elsif user.nil?
        render :json => {:message => "Invalid user token"}.to_json, :status => 401
      elsif access_grant.nil?
        render :json => {:message => "Invalid access token"}.to_json, :status => 401
      end
    end
  end

  def activity_post
    json = ActiveSupport::JSON.decode(request.body)
    access_grant = AccessGrant.find_access(json["access_token"])
    if access_grant
      user = User.where(:token => json["user_token"]).first
      if user && user.valid_api_token?
        activity_post = user.shares.build(:body => json["user_activity_data"])

        # adding photos to activity posts
        if json["media_type"] == ("Photo" || "photo") && json["media_url"].present?
          activity_post.photo_url = json["media_url"]
        end

        if activity_post.valid?
          activity_post.save
          render :json => {:code => 200, :message => "Successfully posted user's activity", :user_token => json["user_token"]}.to_json
        else
          render :json => {:code => 401, :message => "Invalid user activity post"}.to_json
        end
      else
        redirect_to api_user_sign_in_path(:access_token => json["access_token"], :callback_url => "/")
      end
    else
      render :json => {:code => 401, :message => "Could not authenticate access token"}.to_json
    end
  end

  def activity_post_v2
    json = ActiveSupport::JSON.decode(request.body)
    access_grant = AccessGrant.find_access(json["access_token"])
    if access_grant
      user = User.where(:token => json["user_token"]).first
      if user && user.valid_api_token?
        @vincompass_share = VincompassShare.new(:title => json["comment"], :comment => json["comment"],
                                                :wine_name => json["wine_name"],
                                                :year => json["year"],
                                                :grape => json["grape"],
                                                :link => json["link"],
                                                :restaurant_name => json["restaurant_name"],
                                                :region => json["region"],
                                                :producer => json["producer"])
        # adding photos to winshare posts
        #if json["media_type"] == ("Photo" || "photo") && json["media_url"].present?
        #@vincompass_share.photo_url = json["media_url"]
        #end

        if @vincompass_share.valid?
          @vincompass_share.save
          @vincompass_share.promotion.activate_promotion_for_member(user)
          @vincompass_share.post_activity(user)
          render :json => {:code => 200, :message => "Successfully posted user's activity", :user_token => json["user_token"]}.to_json
        else
          render :json => {:code => 401, :message => "Invalid user activity post"}.to_json
        end
      else
        redirect_to api_user_sign_in_path(:access_token => json["access_token"], :callback_url => "/")
      end
    else
      render :json => {:code => 401, :message => "Could not authenticate access token"}.to_json
    end
  end


  def winshare_image(json)
    if json["media_type"] == ("Photo" || "photo") && json["media_url"].present?
      puts json["media_url"]
      return json["media_url"]
    else
      return nil
    end
  end

end
