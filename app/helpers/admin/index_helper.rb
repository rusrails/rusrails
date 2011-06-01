# encoding : utf-8
module Admin::IndexHelper
  def link_to_toggle resourse
    caption = resourse.enabled ? "Вкл." : "Выкл."
    query_hash = {ActiveModel::Naming.singular(resourse) => {:enabled => !resourse.enabled}}
    link_to caption, polymorphic_path([:admin,resourse],query_hash), :method => :put
  end
end
