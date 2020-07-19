class Api::V1::UsersController < ApplicationController
    skip_before_action :authorized, only: [:create]
   
    def profile
      render json: { user: UserSerializer.new(current_user) }, status: :accepted
    end
   
    def create
      @user = User.create(user_params)
      if @user.valid?
        @token = encode_token({ user_id: @user.id })
        render json: { user: UserSerializer.new(@user), jwt: @token }, status: :created
      else
        render json: { error: 'failed to create user' }, status: :not_acceptable
      end
    end

    def admin_create_property
      p "admin_create_property"
      byebug
      if(@user.admin)      
          render json: {info: "user is admin"}
      else
          render json: {info: "user is not admin"}
      end
    end

    def admin_create_lease
      p "admin_create_lease"
        # from front end 
            #admin selects a lease_type
            #admin selects a user
            #admin inputs a monthly rent price
            #admin inputs property address
            #admin bundles these items and submits to via post        
    end

    def admin_get_lease_types
      p "admin_get_lease_types"
    end

    def admin_get_all_users
      p "admin_get_all_users"      
      if(@user.admin)        
          render json: {info: "Success-admin_get_all_users", users: User.all}        
      else        
          render json: {info: "Fail-admin_get_all_users-#{@user.username} is not admin"}
      end
    end

    def admin_get_all_leases
      p "admin_get_all_leases"
      if(@user.admin)        
        render json: {info: "Success-admin_get_all_leases", leases: Lease.all}        
      else        
        render json: {info: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end
    end

    def admin_get_all_active_leases
      p "admin_get_all_active_leases"
      if(@user.admin)        
        render json: {info: "Success-admin_get_all_active_leases", activeLeases: @user.admin_get_all_active_leases()}        
      else        
        render json: {info: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end
    end
    
    def admin_get_all_terminated_leases
      p "admin_get_all_active_leases"
      if(@user.admin)        
        render json: {info: "Success-admin_get_all_terminated_leases", terminatedLeases: @user.admin_get_all_terminated_leases()}        
      else        
        render json: {info: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end
    end

    def admin_get_all_properties
      p "admin_get_all_properties"
      if(@user.admin)        
        render json: {info: "Success-admin_get_all_properties", properties: PropertyAddress.all}        
      else        
        render json: {info: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end
    end

    def admin_get_all_payments
      p "admin_get_all_payments"
    end

    def admin_terminate_lease
      p "admin_terminate_lease"
        # from front end
            #admin selects an active lease
            #admin marks the lease as terminated
            #admin bundles this info into a patch
    end

    def admin_apply_payment_to_lease
      p "admin_apply_payment_to_lease"
        # from front end
            #admin selects an active lease
            #admin enters in a payment amount
            #amin bundles this into a patch
    end

    private
   
    def user_params
      params.require(:user).permit(:username, :password, :firstname, :lastname, :admin)
    end
end