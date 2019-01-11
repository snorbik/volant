class Internal::BaseController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  # before_action :default_format_json
  # serialization_scope :current_user

  layout 'internal'

  private
    def project_scope
      @project_scope ||= ProjectScope.new(session)
    end

    helper_method :project_scope
    
    def pagination_info(scope)
      {
        total: scope.total_count,
        per_page: scope.size,
        total_pages: scope.total_pages,
        pagination_bits: Paginator.new(scope,left: 2,right: 2).pagination_bits,
        current_page: current_page
      }
    end

    def xml_version(path)
      send path,params.except(:action,:controller,:p,:per_page).merge(format: :xml)
    end

    def csv_version(path)
      send path,params.except(:action,:controller,:p,:per_page).merge(format: :csv)
    end

    def per_page
      params[:per_page] || params[:per] || 10
    end

    def current_page
      params[:p] || params[:page] || 1
    end

    def current_order_direction
      if ['true',true,1].include?(params[:asc])
        'asc'
      else
        'desc'
      end
    end

    def current_account
      @current_account ||= current_user.account
    end

    def current_organization
      @current_organization ||= current_account.organization
    end

    def current_year
      params[:year] || nil
    end

    def render_error(model)
      full = model.errors.full_messages.join('. ')
      render json: { errors: model.errors, full_message: "#{full}." }, status: 422
    end

    # HACK - dealing with [] being converted to nil Rails behaviour
    def replace_nil_by_empty_array(hash,name)
      hash[name] = [] if hash[name].nil?
      hash
    end

end
