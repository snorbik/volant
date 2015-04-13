class Message < ActiveRecord::Base

  belongs_to :user
  belongs_to :apply_form
  belongs_to :workcamp  
  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments

  validates_presence_of :user
  validates_inclusion_of :action, in: %w(ask accept reject send infosheet submitted infosheet_all)

  scope :not_sent, lambda { where(sent_at: nil) }
#  validates_presence_of :from,:to,:subject,:body, if: :sending

  ALLOWED_FORM_ACTIONS = [ :accept, :reject, :ask, :infosheet ]
  ALLOWED_WORKCAMP_ACTIONS = [ :infosheet_all ]

  def deliver!
    unless sent?
      ActiveRecord::Base.transaction do
        mail = MessageMailer.standard_email(self)
        mail.deliver
        self.sent_at = Time.now

        if apply_form
          if ALLOWED_FORM_ACTIONS.include?(action_to_perform)
            apply_form.send(action_to_perform).save(validate: false)
          end
        end

        if action_to_perform == :infosheet_all
          workcamp.try(:infosheet_all)
        end

        save!
      end
    end
  end

  def sent?
    !self.sent_at.nil?
  end

  private

  # extract type prefix from action_name
  # outgoing/ask       => ask
  # incoming/infosheet => infosheet
  def action_to_perform
    self.action =~ %r{([a-z_]+)\z}
    $1.try(:to_sym)
  end


end
