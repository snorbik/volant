class ApplyFormsController < ApplicationController

  before_action :find_apply_form, except: [ :index,:create ]

  def index
    if ids = filter[:ids]
      search = ApplyForm.includes(:volunteer)
      render json: search.find(*ids), each_serializer: ApplyFormSerializer
    else
      respond_to do |format|
        format.csv {
          search = add_year_scope(apply_forms)
          send_data search.to_csv, filename: "#{current_year || 'all'}_applications.csv"
        }

        format.json {
          search = apply_forms.page(current_page)
          search = search.includes(:volunteer)
          search = search.order(current_order)
          search = add_year_scope(search)

          if filter[:starred]
            search = search.starred_by(current_user)
          end

          if filter[:tag_ids]
            search = search.joins(:tags).with_tags(*filter[:tag_ids])
          end

          if query = filter[:q].presence
            search = search.query(filter[:q])
          end

          if state = filter[:state]
            # TODO: put those inside model
            case state
            when 'on_project'
              search = search.on_project.count

            when 'just_submitted'
              search = search.just_submitted

            when 'leaves'
              today = Date.today
              search = search.leaves_between(today,today + 7.days)
              
            when 'returns'              
              today = Date.today
              search = search.returns_between(today,today + 7.days)

            when 'without_payment'
              search = search.joins('left outer join payments on payments.apply_form_id = apply_forms.id').state_filter(state)
            else
              search = search.state_filter(state)
            end
          else
            search = search.joins('LEFT OUTER JOIN workcamps ON workcamps.id = current_workcamp_id_cached')
                           .joins('LEFT OUTER JOIN workcamp_assignments ON workcamp_assignments.id = current_assignment_id_cached')
          end

          render json: search,
          meta: { pagination: pagination_info(search) },
          each_serializer: ApplyFormSerializer
        }
      end
    end
  end

  def destroy
    @apply_form.destroy
    head :no_content
  end

  def create
    @apply_form = apply_forms.new(apply_form_params)

    if @apply_form.save
      render_apply_form
    else
      render_error(@apply_form)
    end
  end

  def update
    if  @apply_form.update(apply_form_params)
      render_apply_form
    else
      render_error(@apply_form)
    end
  end


  def show
    render_apply_form
  end

  # ---- non-REST actions

  def cancel
    @apply_form.cancel
    render_apply_form
  end

  def ask
    @apply_form.ask
    render_apply_form
  end

  def reject
    @apply_form.reject
    render_apply_form
  end

  def accept
    @apply_form.accept
    render_apply_form
  end

  def infosheet
    @apply_form.infosheet
    render_apply_form
  end

  def vef
    builder = respond_to do |format|
      format.xml  { Export::VefXml.new(@apply_form) }
      format.html { Export::VefHtml.new(@apply_form) }
      format.pdf { Export::VefPdf.new(@apply_form) }
    end

    send_data builder.data, filename: builder.filename
  end

  private

  def current_order
    case filter[:order].presence
    when 'createdAt' then "#{ApplyForm.table_name}.created_at #{current_order_direction}"
    else "#{Volunteer.table_name}.lastname #{current_order_direction},#{Volunteer.table_name}.firstname #{current_order_direction}"
    end
  end

  def render_state_change
    payload = Payload.new(apply_forms: [ @apply_form ],
                          workcamp_assignments: @apply_form.workcamp_assignments)
    render json: payload, serializer: PayloadSerializer
  end

  def find_apply_form
    @apply_form = ApplyForm.find(params[:id])
  end

  def apply_form_params
    safe_params = params.require(:apply_form).permit(:general_remarks, :motivation, :volunteer_id, :cancelled, :confirmed, :fee,
                                                     tag_ids: [],
                                                     payment_attributes: PaymentSerializer.writable,
                                                     volunteer_attributes: VolunteerSerializer.writable)
    replace_nil_by_empty_array(safe_params,:tag_ids)
  end

  def filter
    params.permit(:starred,:q,:state,:p,:year,:order,:tag_ids => [])
  end

  def render_apply_form
    render json: @apply_form, serializer: ApplyFormSerializer
  end

  def apply_forms
    type = params.delete(:type) || params[:apply_form].try(:delete,:type)

    case type.try(:downcase)
    when 'incoming' then Incoming::ApplyForm
    when 'ltv' then Ltv::ApplyForm
    else Outgoing::ApplyForm
    end
  end


end
