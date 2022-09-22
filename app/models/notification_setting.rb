class NotificationSetting < ApplicationRecord
  WATCHED = :watched
  ASSIGNEE = :assignee
  RESPONSIBLE = :responsible
  MENTIONED = :mentioned
  START_DATE = :start_date
  DUE_DATE = :due_date
  OVERDUE = :overdue
  WORK_PACKAGE_CREATED = :work_package_created
  WORK_PACKAGE_COMMENTED = :work_package_commented
  WORK_PACKAGE_PROCESSED = :work_package_processed
  WORK_PACKAGE_PRIORITIZED = :work_package_prioritized
  WORK_PACKAGE_SCHEDULED = :work_package_scheduled
  NEWS_ADDED = :news_added
  NEWS_COMMENTED = :news_commented
  DOCUMENT_ADDED = :document_added
  FORUM_MESSAGES = :forum_messages
  WIKI_PAGE_ADDED = :wiki_page_added
  WIKI_PAGE_UPDATED = :wiki_page_updated
  MEMBERSHIP_ADDED = :membership_added
  MEMBERSHIP_UPDATED = :membership_updated

  def self.all_settings
    [
      WATCHED,
      ASSIGNEE,
      RESPONSIBLE,
      MENTIONED,
      START_DATE,
      DUE_DATE,
      OVERDUE,
      WORK_PACKAGE_CREATED,
      WORK_PACKAGE_COMMENTED,
      WORK_PACKAGE_PROCESSED,
      WORK_PACKAGE_PRIORITIZED,
      WORK_PACKAGE_SCHEDULED,
      *email_settings
    ]
  end

  def self.email_settings
    [
      NEWS_ADDED,
      NEWS_COMMENTED,
      DOCUMENT_ADDED,
      FORUM_MESSAGES,
      WIKI_PAGE_ADDED,
      WIKI_PAGE_UPDATED,
      MEMBERSHIP_ADDED,
      MEMBERSHIP_UPDATED
    ]
  end

  belongs_to :project
  belongs_to :user

  include Scopes::Scoped
  scopes :applicable

  validates :start_date, :due_date, :overdue, numericality: { only_integer: true,
                                                              allow_nil: true,
                                                              greater_than_or_equal_to: 0,
                                                              less_than_or_equal_to: 168 }
end
