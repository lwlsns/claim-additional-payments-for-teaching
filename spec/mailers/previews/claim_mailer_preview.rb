class ClaimMailerPreview < ActionMailer::Preview
  def submitted
    ClaimMailer.submitted(claim_for(Claim.submitted))
  end

  def approved
    ClaimMailer.approved(claim_for(Claim.approved))
  end

  def rejected
    ClaimMailer.rejected(claim_for(Claim.rejected))
  end

  def payment_confirmation
    claim = claim_for(Claim.joins(:payment).where("payments.gross_value IS NOT NULL"))
    ClaimMailer.payment_confirmation(claim, DateTime.now.to_time.to_i)
  end

  private

  def claim_for(scope)
    scoped_by_policy(scope).last
  end

  def scoped_by_policy(scope)
    if (policy = Policies[params[:policy]])
      scope.by_policy(policy)
    else
      scope
    end
  end
end
