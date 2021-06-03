class Attendance < ApplicationRecord
	include Authable
  include Iamport

  belongs_to :project
  belongs_to :tutee

  enum status: %i(trial full)

  ransacker :status, formatter: proc {|v| statuses[v]}

  enum pay_status: %i(unpaid paid)

  ransacker :pay_status, formatter: proc {|v| pay_statuses[v]}

  enum refund_status: %i(yet complete)

  ransacker :refund_status, formatter: proc {|v| refund_statuses[v]}

  def check_payment
    code, response = Iamport.iamport_payment(self.imp_uid)
    
    status, paid_amount, imp_uid, merchant_uid = response.values_at('status', 'amount', 'imp_uid', 'merchant_uid')
    
    if code.zero? && self.unpaid? && self.trial?
      self.paid!
      self.full!
      self.project.running!
    end
  end

  def targets
    self.tutee
  end
end
