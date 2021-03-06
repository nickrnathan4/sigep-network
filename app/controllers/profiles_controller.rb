class ProfilesController < ApplicationController

 before_action :confirm_logged_in
 before_action :set_dropdown_arrays

 helper_method :sort_column, :sort_direction

  def index
    if !params[:filter].blank?
      if !params[:filter].match(/\A[0-9]+\Z/)
        @profiles = Profile.search(params[:filter])
      else
        @profiles = Profile.search_year(params[:filter])
      end
    else
      @profiles = Profile.order(sort_column + " " + sort_direction)
    end  
  end

  def show
    if params[:user_id]
      user_id = params[:id]
      sync_email(user_id)
      @user = User.find(user_id)
      profile_id = lookup_profile_id(user_id)
      @profile = Profile.find(profile_id)
    else
      begin
        @profile = Profile.find(params[:id])
      rescue
        redirect_to(:action => 'index')
      end
    end
  end

  def new
    @profile = Profile.new()
    @user = User.find(params[:id])
  end

  def create
    @profile = Profile.new(profile_params)
    @user = User.find(params[:id])
    @profile.user_id = @user.id
    @profile.email = @user.email
    if @profile.save
      flash[:notice] = "Profile #{@profile.first_name} #{@profile.last_name} created successfully."
      flash[:status] = "alert-success"
			redirect_to(:action => 'show', :id => @user.id, :user_id => true)
		else
			render('new')
		end
  end

  def edit
    if params[:user_id]
      @profile = Profile.find(lookup_profile_id(params[:id]))
    else
      @profile = Profile.find(params[:id])
    end
    if session[:user_id] != @profile.user_id
        flash[:notice] = "Invalid Access: you are not authorized to edit this profile."
        flash[:status] = "alert-warning"
        redirect_to(:action => 'index')
    end
  end

  def update
    @profile = Profile.find(params[:id])
    if @profile.update_attributes(profile_params)
      flash[:notice] = "Profile updated successfully."
      flash[:status] = "alert-success"
      redirect_to(:action => 'show', :id => @profile.id)
		else
			render('edit')
		end
	end

	def delete
    @profile = Profile.find(params[:id])
	end

	def destroy
    profile = Profile.find(params[:id]).destroy
    flash[:notice] = "Profile destroyed successfully."
		redirect_to(:action => 'index')
	end


	private

  def profile_params
    params.require(:profile).permit(:first_name,
                                    :last_name,
                                    :class_year,
                                    :college_major_minor,
                                    :residence_state,
                                    :residence_city,
                                    :residence_country,
                                    :industry,
                                    :career_details,
                                    :company_name,
                                    :advanced_degrees,
                                    :bio,
                                    :email,
                                    :linkedin_link, 
                                    :facebook_link,                              
                                    :avatar,
                                    :profiles)
	end

  def sync_email(user_id)
    # Ensures that the profile's email is the same as the user's email
    user = User.find(user_id)
    profile = Profile.find( lookup_profile_id(user_id) )
    if user.email != profile.email
      if !profile.update_attributes(:email => user.email)
        flash[:notice] = "Profile email failed to sync."
        flash[:status] = "alert-danger"
      end
    end
  end

  def lookup_profile_id(user_id)
    profile = Profile.where(:user_id => user_id).first
    profile.id
  end

  def sort_column
    params[:sort] || "last_name"
  end

  def sort_direction
    params[:direction] || "asc"
  end

  def set_dropdown_arrays
    @industries = [ 
    '',  
    'Accounting',
    'Administrative',
    'Advertising',
    'Aerospace',
    'Agriculture',
    'Apparel & Accessories',
    'Arts/Design',
    'Athletics',
    'Automotive',
    'Banking',
    'Broadcasting',
    'Brokerage',
    'Biotechnology',
    'Call Centers',
    'Chemical',
    'Communications',
    'Consulting',
    'Consumer Products',
    'Defense',
    'Education/Teaching',
    'Electronics',
    'Energy/Environment',
    'Engineering/Architecture',
    'Entertainement',
    'Executive Search',
    'Fashion/Retail',
    'Finance, Non-Banking',
    'Food, Beverage',
    'Government',
    'Health Care',
    'Information Technology/Services',
    'Insurance',
    'Investment Banking',
    'Legal',
    'Manufacturing/Production',
    'Marketing',
    'Media/Journalism',
    'Motion Picture & Video',
    'Music',
    'Non-Profit/Public Service',
    'Online Auctions',
    'Other',
    'Pension Funds',
    'Pharmaceuticals',
    'Private Equity',
    'Public Relations',
    'Publishing',
    'Real Estate',
    'Research',
    'Sales',
    'Sciences',
    'Securities & Commodity Exchanges',
    'Service/Hospitality',
    'Software',
    'Sports',
    'Technology',
    'Telecommunications',
    'Television',
    'Transportation',
    'Venture Capital']
    
    @states = ['','international',
      'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS',
      'KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY',
      'NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV',
      'WI','WY','AS','DC','FM','GU','MH','MP','PW','PR']
  end

end
