window.up_or_down = (allocated,revised ) ->
            if allocated > revised
                return ["קטן","מ"]
            else if allocated < revised
                return ["הוגדל","מ"]
            else
                return ["עמד","על"]

window.increase_or_cut = (allocated,revised ) ->
            if allocated > revised
                return "קיצוץ של"
            else
                return "תוספת של"

window.transfers_by_year = (year) ->
            return arr = $.grep(pageModel.changeGroups.models, (el,i) ->
                el.attributes.year is year)

window.num_of_transfers_in_year_text = (year) ->
            arr = transfers_by_year(year)
            if arr.length > 1
                return String(arr.length) + " העברות"
            else
                return "העברה אחת"




class HeaderAnalyzer

    shouldParticipate: () ->
        false

    analyze: () ->
        ""

class BudgetAnalyzer extends HeaderAnalyzer

    shouldParticipate: () ->
        window.pageModel.get('budgetCode')?

class CurrentBudgetAnalyzer extends BudgetAnalyzer

    shouldParticipate: () ->
        window.pageModel.get('currentItem').attributes.net_allocated?

    analyze: () ->
        bh = pageModel.budgetHistory;
        obj = { 
            current: pageModel.get('currentItem').toJSON(),
            previous: bh.models[bh.length - 2].toJSON()
        }
        window.JST.header__current_budget( obj )

class ChangedThisYearAnalyzer extends BudgetAnalyzer

    shouldParticipate: () ->
        year = window.pageModel.get('currentItem').attributes.year
        transfers_by_year(year).length > 0

    analyze: () ->
        window.JST.header__changed_this_year( pageModel.get('currentItem').toJSON())



class HeaderView extends Backbone.View

    initialize: ->
        analyzers = [
            new CurrentBudgetAnalyzer()
            new ChangedThisYearAnalyzer()
        ]

        @analyzers = []
        for analyzer in analyzers
            if analyzer.shouldParticipate()
                @analyzers.push( analyzer )

        @render()

    render: ->
        @$el.html('')
        for analyzer in @analyzers
            @$el.append( analyzer.analyze() )

$( ->
    if window.pageModel.get('budgetCode')?
        callback = _.after(2, -> window.headerView = new HeaderView(el: window.pageModel.article.find(".brief")))
        window.pageModel.on('ready-budget-history', callback)
        window.pageModel.on('ready-breadcrumbs', callback)
)
