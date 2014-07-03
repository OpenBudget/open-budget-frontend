class HeaderAnalyzer

    shouldParticipate: () ->
        false

    analyze: () ->
        ""

class BudgetAnalyzer extends HeaderAnalyzer

    shouldParticipate: () ->
        window.pageModel.get('budgetCode')?

class CurrentBudgetAnalyzer extends BudgetAnalyzer

    analyze: () ->
        window.JST.header__current_budget( pageModel.get('currentItem').toJSON() )

class ChangedThisYearAnalyzer extends BudgetAnalyzer

    analyze: () ->
        window.JST.header__changed_this_year( pageModel.get('currentItem').toJSON() )


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
    window.pageModel.on('ready', ->
        window.headerView = new HeaderView(el: $("#brief"))
    )
)
