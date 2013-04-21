# coding: utf-8
class PageDecorator < ContentDecorator
  delegate_all

  def menu
    return unless renderer == 'md'
    h.render 'pages/menu', markdown_renderer: markdown_renderer
  end

end
