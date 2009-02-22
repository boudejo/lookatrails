module ResourceController
  class FailableActionOptions
    extend ResourceController::Accessors
    
    scoping_reader :success, :fails, :nochanges, :vfails # Added nochanges, vfails
    alias_method :failure, :fails
    
    block_accessor :before
    
    def initialize
      @success = ActionOptions.new
      @fails   = ActionOptions.new
      @nochanges = ActionOptions.new # Added
      @vfails = ActionOptions.new # Added
    end
    
    delegate :flash, :flash_now, :after, :response, :wants, :to => :success
    
    def dup
      returning self.class.new do |duplicate|
        duplicate.instance_variable_set(:@success, success.dup)
        duplicate.instance_variable_set(:@fails,   fails.dup)
        duplicate.instance_variable_set(:@nochanges, nochanges.dup) # Added
        duplicate.instance_variable_set(:@vfails, vfails.dup) # Added
        duplicate.instance_variable_set(:@before,  before.dup) unless before.nil?
      end
    end
  end
end