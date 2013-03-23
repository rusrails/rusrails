mySettings =
  previewParserPath: "/says/preview"
  onShiftEnter:    {keepDefault:false, openWith:'\n\n'}
  markupSet: [
    {name:'First Level Heading', key:'1', placeHolder:'Your title here...', closeWith: (markItUp) -> miu.markdownTitle(markItUp, '=') }
    {name:'Second Level Heading', key:'2', placeHolder:'Your title here...', closeWith: (markItUp) -> miu.markdownTitle(markItUp, '-') }
    {name:'Heading 3', key:'3', openWith:'### ', placeHolder:'Your title here...' }
    {name:'Heading 4', key:'4', openWith:'#### ', placeHolder:'Your title here...' }
    {name:'Heading 5', key:'5', openWith:'##### ', placeHolder:'Your title here...' }
    {name:'Heading 6', key:'6', openWith:'###### ', placeHolder:'Your title here...' }
    {separator:'---------------' }
    {name:'Bold', key:'B', openWith:'**', closeWith:'**'}
    {name:'Italic', key:'I', openWith:'_', closeWith:'_'}
    {separator:'---------------' }
    {name:'Bulleted List', openWith:'- ' }
    {name:'Numeric List', openWith: (markItUp) -> markItUp.line+'. '}
    {separator:'---------------' }
    {name:'Picture', key:'P', replaceWith:'![[![Alternative text]!]]([![Url:!:http://]!] "[![Title]!]")'}
    {name:'Link', key:'L', openWith:'[', closeWith:']([![Url:!:http://]!] "[![Title]!]")', placeHolder:'Your text to link here...' }
    {separator:'---------------'}
    {name:'Quotes', openWith:'> '}
    {name:'Code', openWith:'`', closeWith:'`'}
    {name:'Code Block', openWith:'\n\n```ruby\n', closeWith:'\n```'}
    {separator:'---------------'}
    {name:'Preview', call:'preview', className:"preview"}
  ]

miu =
  markdownTitle: (markItUp, char) ->
    heading = ''
    n = $.trim(markItUp.selection||markItUp.placeHolder).length
    heading += char for i in [0..n]
    '\n'+heading

$ -> $("textarea.markitup").markItUp(mySettings)

$ ->
  $('#preview_link').click ->
    $.get $(this).attr('href'), {text: $('#say_text').val()}, (data) ->
      $('#preview').html data
    false
