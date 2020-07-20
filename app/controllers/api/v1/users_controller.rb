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

    def validate_params(params, parameter)
      params[parameter].each do 
        |id, value| 
        if value.blank?
          @fail_id = id
          return false
        end            
      end
      return true
    end

    def admin_create_property  
      if(!@user.admin)
        return render json: {info: "Fail-admin_create_property-#{@user.username} is not admin"}        
      end

      # check properties
      if !validate_params(params, "property")
        return render json: {status: 400, info: "Bad Request. Required parameters #{@fail_id} must not be empty."}
      end
      
      createdProperty = PropertyAddress.create(
        street_address: params["property"]["streetAddress"],
        apartment: params["property"]["apartment"],          
        city: params["property"]["city"],
        state: params["property"]["state"],
        zip: params["property"]["zip"]
      )
      if createdProperty.valid?
        render json: {info: "Created PropertyAddress.", createdProperty: createdProperty}, status: :created
      else
        render json: {info: "Failed to create property_address."}
      end        
    end

    def admin_create_lease
      if(!@user.admin)
        return render json: {info: "Fail-admin_create_lease-#{@user.username} is not admin"}        
      end
      if !validate_params(params, "leaseToCreate")
        return render json: {status: 400, info: "Bad Request-admin_create_lease. Required parameter #{@fail_id} must not be empty."}
      end       
                            
      foundLeaseType = LeaseType.find_by_id(params["leaseToCreate"]["lease_type_id"])      
      if !foundLeaseType                 
        return render json: {status: 404, info: "Bad Request-admin_create_lease. Id LeaseType Id#{params["leaseToCreate"]["lease_type_id"]} was not found."}
      end

      propertyForNewLease = PropertyAddress.find_by_id(params["leaseToCreate"]["property_id"])      
      if !propertyForNewLease      
        return render json: {status: 404, info: "Bad Request-admin_create_lease. PropertyAddress Id#{params["leaseToCreate"]["property_id"]} was not found."}
      end

      renterForNewLease = User.find_by_id(params["leaseToCreate"]["user_id"])      
      if !renterForNewLease      
        return render json: {status: 404, info: "Bad Request-admin_create_lease. User Id#{params["leaseToCreate"]["user_id"]} was not found."}
      end

      random_start_date = @user.rand_future_date(90)
      random_end_date = random_start_date >> foundLeaseType.duration_months

      createdLease = Lease.create(
        user_id: params["leaseToCreate"]["user_id"],        
        property_address_id: params["leaseToCreate"]["property_id"],
        lease_type_id: params["leaseToCreate"]["lease_type_id"],          
        monthly_rent_price: params["leaseToCreate"]["monthly_rent_price"],
        start_date: random_start_date, # params["leaseToCreate"]["start_date"],
        end_date: random_end_date, # params["leaseToCreate"]["end_date"],
        first_month_rent: params["leaseToCreate"]["first_month_rent"],
        last_month_rent: params["leaseToCreate"]["last_month_rent"],
        security_deposit: params["leaseToCreate"]["security_deposit"],
        status: true
      )
      if createdLease.valid?
        render json: {status: 200, info: "Successfully created lease", foundLeaseType: foundLeaseType}, status: :created
      else
        render json: {status: 500, info: "Failed to create lease."}
      end    
       
    end

    def admin_create_payment
      if(!@user.admin)
        return render json: {info: "Fail-admin_create_payment-#{@user.username} is not admin"}        
      end
      
      if !validate_params(params, "payment")
        return render json: {status: 400, info: "Bad Request-admin_create_payment. Required parameter #{@fail_id} must not be empty."}
      end    
      foundLease = Lease.find(params["payment"]["lease_id"])      
      if foundLease
        
        createdPayment = Payment.create(
          lease_id: foundLease.id,
          amount: BigDecimal(params["payment"]["amount"])                        
        )
        if createdPayment.valid?
          render json: {info: "Created Payment.", createdPayment: createdPayment}, status: :created
        else
          render json: {info: "Failed to create payment."}
        end  
      else
        render json: {info: "Invalid lease submited"}
      end
    end

    def admin_get_all_users
      if(!@user.admin)
        return render json: {info: "Fail-admin_get_all_users-#{@user.username} is not admin"}
      end     
      render json: {info: "Success-admin_get_all_users", users: User.all}              
    end

    def admin_get_all_lease_types
      if(!@user.admin)
        return render json: {info: "Fail-admin_get_all_lease_types-#{@user.username} is not admin"}
      end      
      render json: {info: "Success-admin_get_all_lease_types", lease_types: LeaseType.all}      
    end

    def admin_get_all_leases      
      if(!@user.admin)
        return render json: {info: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end        
      render json: {info: "Success-admin_get_all_leases", leases: Lease.all}      
    end

    def admin_get_all_active_leases      
      if(!@user.admin)
        return render json: {info: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end            
      render json: {info: "Success-admin_get_all_active_leases", activeLeases: @user.admin_get_all_active_leases()}              
    end
    
    def admin_get_all_terminated_leases      
      if(!@user.admin)
        return render json: {info: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end         
      return render json: {info: "Success-admin_get_all_terminated_leases", terminatedLeases: @user.admin_get_all_terminated_leases()}              
    end

    def admin_get_all_properties      
      if(!@user.admin)
        return render json: {info: "Fail-admin_get_all_leases-#{@user.username} is not admin"}
      end      
      render json: {info: "Success-admin_get_all_properties", properties: PropertyAddress.all}              
    end

    def admin_get_all_payments
      if(!@user.admin)
        return render json: {info: "Fail-admin_get_all_payments-#{@user.username} is not admin"}
      end      
      render json: {info: "Success-admin_get_all_payments", payments: Payment.all}              
    end

    def admin_terminate_lease
      if(!@user.admin)
        return render json: {info: "Fail-admin_terminate_lease-#{@user.username} is not admin"}
      end 

      if !validate_params(params, "leaseToTerminate")
        return render json: {status: 400, info: "Bad Request. Required parameter #{@fail_id} must not be empty."}
      end           
      foundLease = Lease.find(params["leaseToTerminate"]["lease_id"])      
      if foundLease
        foundLease.update(status: false)
        return render json: {info: "Success. Lease with id=#{params["leaseToTerminate"]["lease_id"]} was terminated."}
      else
        return render json: {status: 404, info: "Bad Request. Lease with id=#{id} was not found."}
      end
    end

    def admin_apply_payment_to_lease
      if(!@user.admin)
        return render json: {info: "Fail-admin_apply_payment_to_lease-#{@user.username} is not admin"}
      end 

      if !validate_params(params, "leaseToAddPaymentTo")
        return render json: {status: 400, info: "Bad Request-admin_apply_payment_to_lease. Required parameter #{@fail_id} must not be empty."}
      end       
                            
      foundLease = Lease.find_by_id(params["leaseToAddPaymentTo"]["lease_id"])      
      if !foundLease                 
        return render json: {status: 404, info: "Bad Request-admin_apply_payment_to_lease. Id Lease Id#{params["leaseToAddPaymentTo"]["lease_id"]} was not found."}
      end

      paymentForLease = Payment.find_by_id(params["leaseToAddPaymentTo"]["payment_id"])      
      if !paymentForLease      
        return render json: {status: 404, info: "Bad Request-admin_apply_payment_to_lease. Payment Id#{params["leaseToAddPaymentTo"]["payment_id"]} was not found."}
      end
      
      foundLease.update(balance: (foundLease.balance - paymentForLease.amount))
      return render json: {info: "Success. Payment with id#{paymentForLease.id} of $#{paymentForLease.amount.to_digits()} was made to lease with id=#{foundLease.id} was terminated."}
      
    end

    def admin_manually_apply_monthly_rent_to_active_leases
      leases = Lease.where(status: true)
      
      leases.each do |lease| 
        lease.update(balance: lease.balance + lease.monthly_rent_price)
      end
      return render json: {info: "Success. Lease balances have been each charged their monthly rent"}
    end
      
    private
   
    def user_params
      params.require(:user).permit(:username, :password, :firstname, :lastname, :admin)
    end
end