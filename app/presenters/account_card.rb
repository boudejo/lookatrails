class AccountCard < ActivePresenter::Base
  presents :account, :accountcontactcard
  
  before_save :assign_account_to_accountcontactcard
  
  def assign_account_to_accountcontactcard
    @accountcontactcard.accountcontactable = @account
  end

  # Instance Methods
  def to_s(type = '')
      case type
        when "full"
          @accountcontactcard.to_s('name')
        else
          @account.id
      end
  end
  
end