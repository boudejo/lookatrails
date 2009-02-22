module Crm::OpportunitiesHelper
  
  def probability_status_class(probability, status)
    if probability == '25%' then
      return 'probability_low status_'+status
    elsif probability == '75%' then
      return 'probability_med status_'+status
    end
  end
  
end
