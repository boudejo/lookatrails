module ResourceController
  module Actions
    
    def index
      load_collection
      before :index
      response_for :index
    end
    
    def show
      load_object
      before :show
      response_for :show
    rescue ActiveRecord::RecordNotFound
      response_for :show_fails
    end

    def create
      build_object
      load_object
      before :create
      if object.save
        set_flash :create, :success
        after :create
        response_for :create
      else
        if object.errors.empty?
          set_flash :create_fails, :error
          after :create_fails
          response_for :create_fails
        else
          set_flash :create_vfails, :notice
          after :create_fails
          response_for :create_vfails
        end
      end
    end

    def update
      load_object
      before :update
      if update_nochanges? == true then
        object.attributes = object_params
      end
      if (object.changed? == false && update_nochanges? == true) then
        set_flash :update_nochanges, :notice
        response_for :update_nochanges
      else
        if object.update_attributes object_params
          set_flash :update, :success
          after :update
          response_for :update
        else
          if object.errors.empty?
            set_flash :update_fails, :error
            after :update_fails
            response_for :update_fails
          else
            set_flash :update_vfails, :notice
            after :update_fails
            response_for :update_vfails
          end
        end
      end
    end

    def new
      build_object
      load_object
      before :new_action
      response_for :new_action
    end

    def edit
      load_object
      before :edit
      response_for :edit
    end

    def destroy
      load_object
      before :destroy
      if object.destroy
        set_flash :destroy, :success
        after :destroy
        response_for :destroy
      else
        set_flash :destroy_fails, :error
        after :destroy_fails
        response_for :destroy_fails
      end
    end
    
  end
end
