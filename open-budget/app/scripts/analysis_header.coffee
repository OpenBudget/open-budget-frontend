define([
  'backbone',
  'models',
  'underscore',
  'tpl!templates/header__current_budget',
  'tpl!templates/header__changed_this_year'
  ], (Backbone, models, _, header__current_budget, header__changed_this_year) ->

    window.up_or_down = (allocated,revised ) ->
                if allocated > revised
                    return ["קטן","מ"]
                else if allocated < revised
                    return ["הוגדל","מ"]
                else
                    return ["עמד","על"]

    window.increase_or_cut = (allocated,revised ) ->
                if allocated > revised
                    return "קיצוץ זה הביא"
                else
                    return "תוספת זו הביאה"

    window.transfers_by_year = (year) ->
                if pageModel.changeGroups?
                    return arr = $.grep(pageModel.changeGroups.models, (el,i) ->
                        el.attributes.year is year)
                else
                    return []

    window.num_of_transfers_in_year_text = (year) ->
                arr = transfers_by_year(year)
                if arr.length > 1
                    return String(arr.length) + " העברות"
                else
                    return "שינויים"



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
            # make sure currentItem exists - /equivs api can return an empty result
            window.pageModel.get('currentItem')?.attributes.net_allocated?

        analyze: () ->
            header__current_budget( pageModel.get('currentItem').toJSON() )

    class ChangedThisYearAnalyzer extends BudgetAnalyzer

        shouldParticipate: () ->
            res = false
            # make sure currentItem exists - /equivs api can return an empty result
            if window.pageModel.get('currentItem')
                year = window.pageModel.get('currentItem').get('year')
                res = transfers_by_year(year).length > 0

            return res


        analyze: () ->
            header__changed_this_year( pageModel.get('currentItem').toJSON())



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

    if models.pageModel.get('budgetCode')?
        callback = _.after(2, -> window.headerView = new HeaderView(el: models.pageModel.article.find(".brief")))
        models.pageModel.on('ready-budget-history', callback)
        models.pageModel.on('ready-breadcrumbs', callback)

    HeaderView
)
