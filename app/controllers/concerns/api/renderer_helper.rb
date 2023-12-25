module Api
    module RendererHelper
      def render_success(payload, message = "", meta_data = {}, next_action = {})
        render(json: base_response(payload, meta_data, message, "001", :SUCCESS, next_action), status: :ok)
      end
  
      def render_error(payload, message = "", meta_data = {}, next_action = {}, code = "002")
        render(json: base_response(payload, meta_data, message, code, :ERROR, next_action), status: :unprocessable_entity)
      end
  
      def render_resource_not_found(meta_data = {})
        render(json: base_response({}, meta_data, "No Record Found", "003", :NOT_FOUND, {}), status: :not_found)
      end
  
      def render_content_not_found(meta_data = {})
        render(json: base_response({}, meta_data, "Content not found", "003", :no_content, {}), status: :no_content)
      end    
  
      def render_unauthorized(message = "unauthorized", meta_data = {}, next_action = {})
        render(json: base_response({}, meta_data, message, "005", :UNAUTHORIZED, next_action), status: :unauthorized)
      end
  
      def render_collection(payload, serializer, meta_data = {}, scope = {})
        render(json: base_response(ActiveModelSerializers::SerializableResource.new(payload, each_serializer: serializer, scope: scope), meta_data, "success", "001", :SUCCESS, {}), status: :ok)
      end
  
      def render_resource_not_destroyed(resource, meta_data = {})
        render(json: {
          payload: t('api.errors.destroy_failed', entity: resource.class),
          meta: meta_data
        }, status: 422)
      end
  
      private
        def base_response(payload, meta_data, message, code, status, nextAction)
          {
            payload: payload,
            meta: meta_data,
            status: {
              message: message,
              code: code,
              status: status
            }
          }
        end
    end
end