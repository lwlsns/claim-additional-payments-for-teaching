module ClaimsHelper
  def fields_from_govuk_verify(claim)
    fields = []
    fields << translate("govuk_verify_fields.first_name") if claim.govuk_verify_fields.include?("first_name")
    fields << translate("govuk_verify_fields.middle_name") if claim.govuk_verify_fields.include?("middle_name")
    fields << translate("govuk_verify_fields.surname") if claim.govuk_verify_fields.include?("surname")
    fields << translate("govuk_verify_fields.address") if claim.address_from_govuk_verify?
    fields << translate("govuk_verify_fields.date_of_birth") if claim.govuk_verify_fields.include?("date_of_birth")
    fields << translate("govuk_verify_fields.payroll_gender") if claim.payroll_gender_verified?
    fields.to_sentence
  end

  def eligibility_answers(claim)
    claim.policy::EligibilityAnswersPresenter.new(claim.eligibility).answers
  end

  def verify_answers(claim)
    [].tap do |a|
      a << [translate("govuk_verify_fields.first_name").capitalize, claim.first_name] if claim.name_verified?
      a << [translate("govuk_verify_fields.middle_name").capitalize, claim.middle_name] if claim.name_verified? && claim.middle_name.present?
      a << [translate("govuk_verify_fields.surname").capitalize, claim.surname] if claim.name_verified?
      a << [translate("govuk_verify_fields.address").capitalize, sanitize(claim.address("<br>").html_safe, tags: %w[br])] if claim.address_from_govuk_verify?
      a << [translate("govuk_verify_fields.date_of_birth").capitalize, l(claim.date_of_birth)] if claim.date_of_birth_verified?
      a << [translate("govuk_verify_fields.payroll_gender").capitalize, t("answers.payroll_gender.#{claim.payroll_gender}")] if claim.payroll_gender_verified?
    end
  end

  def identity_answers(claim)
    [].tap do |a|
      a << [translate("questions.name"), claim.full_name, "name"] unless claim.name_verified?
      a << [translate("questions.address"), claim.address, "address"] unless claim.address_from_govuk_verify?
      a << [translate("questions.date_of_birth"), date_of_birth_string(claim), "date-of-birth"] unless claim.date_of_birth_verified?
      a << [translate("questions.payroll_gender"), t("answers.payroll_gender.#{claim.payroll_gender}"), "gender"] unless claim.payroll_gender_verified?
      a << [translate("questions.teacher_reference_number"), claim.teacher_reference_number, "teacher-reference-number"]
      a << [translate("questions.national_insurance_number"), claim.national_insurance_number, "national-insurance-number"]
      a << [translate("questions.email_address"), claim.email_address, "email-address"]
    end
  end

  def student_loan_answers(claim)
    [].tap do |a|
      a << [translate("questions.has_student_loan"), (claim.has_student_loan ? "Yes" : "No"), "student-loan"]
      a << [translate("questions.student_loan_country"), claim.student_loan_country.titleize, "student-loan-country"] if claim.student_loan_country.present?
      a << [translate("questions.student_loan_how_many_courses"), claim.student_loan_courses.humanize, "student-loan-how-many-courses"] if claim.student_loan_courses.present?
      a << [translate("questions.student_loan_start_date.#{claim.student_loan_courses}"), t("answers.student_loan_start_date.#{claim.student_loan_courses}.#{claim.student_loan_start_date}"), "student-loan-start-date"] if claim.student_loan_courses.present?
    end
  end

  def payment_answers(claim)
    [].tap do |a|
      a << ["Name on bank account", claim.banking_name, "bank-details"]
      a << ["Bank sort code", claim.bank_sort_code, "bank-details"]
      a << ["Bank account number", claim.bank_account_number, "bank-details"]
      a << ["Building society roll number", claim.building_society_roll_number, "bank-details"] if claim.building_society_roll_number.present?
    end
  end

  def date_of_birth_string(claim)
    claim.date_of_birth && l(claim.date_of_birth)
  end
end
