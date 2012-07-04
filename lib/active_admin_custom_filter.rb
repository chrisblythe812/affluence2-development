module ActiveAdmin

  class FilterFormBuilder
    include ::ActionView::Helpers::OutputSafetyHelper

    def filter_custom_input( method, options = {} )
      field_name = method

      safe_join(
          [
              label( field_name, I18n.t( 'active_admin.search_field', :field => options[:label] ) ),
              text_field( field_name )
          ],
          "\n"
      )
    end

  end

end