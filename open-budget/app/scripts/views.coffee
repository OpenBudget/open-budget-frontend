class IssueView extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                @pageModel.on 'change:currentItem', () =>
                        @currentItem = @pageModel.get('currentItem')
                        @render()
                @currentItem = @pageModel.get('currentItem')
                if @currentItem?
                        @render()

class IssueNumber extends IssueView

        render: ->
                code = @currentItem.get('code')
                @$('a').remove()
                $("<a>").toggleClass('home').attr("href","#").text('#').appendTo(@el)
                last = code.length/2-1
                for i in [1..last]
                        part = code[i*2..i*2+1]
                        console.log i,part
                        $("<a>").attr("href","#").text(part).toggleClass('active',i==last).appendTo(@el)

class IssueTitle extends IssueView

        render: ->
                title = @currentItem.get('title')
                $(@el).text(title)
                        
$( ->
        window.issueNumber = new IssueNumber(el: $("#issue-num"))
        window.issueTitle = new IssueTitle(el: $("header > h1"))
)          
                        
              