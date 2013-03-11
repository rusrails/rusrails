# coding: utf-8
class DiscussionDecorator < ContentDecorator
  delegate_all

  def author
    h.content_tag :span, source.author.try(:name) || 'неизвестный', :class => (source.author.try(:admin?) ? :admin_name : nil)
  end

  def textile_html(lite_mode = false)
    super(lite_mode, true)
  end

end
