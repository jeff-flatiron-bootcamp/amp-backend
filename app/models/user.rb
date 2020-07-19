class User < ApplicationRecord
    has_secure_password
    has_many :user_contacts
    validates :username, uniqueness: { case_sensitive: false }    
    
    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    def prior_address
        #User.all[2].user_contacts.find_by(address_type: "PRIOR")
        self.user_contacts.find_by(address_type: "PRIOR")
    end

    def apply_payment_to_lease(lease, payment)
        lease.balance = lease.balance - payment.amount
        lease.save()
    end

    def admin_get_all_active_leases
        Lease.where(status: true)
    end

    def admin_get_all_terminated_leases
        Lease.where(status: false)
    end

    def admin_get_leases_with_balance()
        Lease.where(["balance > ?", 0.0])
    end

    def admin_check
        return self.admin
    end
end
