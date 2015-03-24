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
            if @currentItem
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
            if @currentItem
                title = @currentItem.get('title')
                $(@el).text(title)

$( ->
        if window.pageModel.article?
            window.issueNumber = new IssueNumber(el: window.pageModel.article.find(".current .issue-num"))
            window.issueTitle = new IssueTitle(el: window.pageModel.article.find("header h1"))
)
