module Trestle
  class Resource
    class Controller
      module Actions
        def index
          respond_to do |format|
            format.html
            format.json { render json: collection }

            yield format if block_given?
          end
        end

        def new
          self.instance = admin.build_instance(params.key?(admin.parameter_name) ? admin.permitted_params(params) : {}, params)

          respond_to do |format|
            format.html
            format.json { render json: instance }

            yield format if block_given?
          end
        end

        def create
          self.instance = admin.build_instance(admin.permitted_params(params), params)

          if admin.save_instance(instance, params)
            respond_to do |format|
              format.html do
                flash[:message] = flash_message("create.success", title: "Success!", message: "The %{lowercase_model_name} was successfully created.")
                redirect_to_return_location(:create, instance, default: admin.instance_path(instance))
              end
              format.json { render json: instance, status: :created, location: admin.instance_path(instance) }

              yield format if block_given?
            end
          else
            respond_to do |format|
              format.html do
                flash.now[:error] = flash_message("create.failure", title: "Warning!", message: "Please correct the errors below.")
                render "new", status: :unprocessable_entity
              end
              format.json { render json: instance.errors, status: :unprocessable_entity }

              yield format if block_given?
            end
          end
        end

        def show
          if admin.singular? && instance.nil?
            respond_to do |format|
              format.html { redirect_to action: :new }
              format.json { head :not_found }

              yield format if block_given?
            end
          else
            respond_to do |format|
              format.html
              format.json { render json: instance }

              yield format if block_given?
            end
          end
        end

        def edit
          if admin.singular? && instance.nil?
            respond_to do |format|
              format.html { redirect_to action: :new }
              format.json { head :not_found }

              yield format if block_given?
            end
          else
            respond_to do |format|
              format.html
              format.json { render json: instance }

              yield format if block_given?
            end
          end
        end

        def update
          admin.update_instance(instance, admin.permitted_params(params), params)

          if admin.save_instance(instance, params)
            respond_to do |format|
              format.html do
                flash[:message] = flash_message("update.success", title: "Success!", message: "The %{lowercase_model_name} was successfully updated.")
                redirect_to_return_location(:update, instance, default: admin.instance_path(instance))
              end
              format.json { render json: instance, status: :ok }

              yield format if block_given?
            end
          else
            respond_to do |format|
              format.html do
                flash.now[:error] = flash_message("update.failure", title: "Warning!", message: "Please correct the errors below.")
                render "show", status: :unprocessable_entity
              end
              format.json { render json: instance.errors, status: :unprocessable_entity }

              yield format if block_given?
            end
          end
        end

        def destroy
          success = admin.delete_instance(instance, params)

          respond_to do |format|
            format.html do
              if success
                flash[:message] = flash_message("destroy.success", title: "Success!", message: "The %{lowercase_model_name} was successfully deleted.")
                redirect_to_return_location(:destroy, instance, default: admin.path(:index))
              else
                flash[:error] = flash_message("destroy.failure", title: "Warning!", message: "Could not delete %{lowercase_model_name}.")

                if self.instance = admin.find_instance(params)
                  redirect_to_return_location(:update, instance, default: admin.instance_path(instance))
                else
                  redirect_to_return_location(:destroy, instance, default: admin.path(:index))
                end
              end
            end
            format.json { head :no_content }

            yield format if block_given?
          end
        end
      end
    end
  end
end