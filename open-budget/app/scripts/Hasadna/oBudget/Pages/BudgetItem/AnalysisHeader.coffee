define([
  'backbone',
  'underscore',
  'templates/header__current_budget.html',
  'templates/header__changed_this_year.html'
  ], (Backbone, _, header__current_budget, header__changed_this_year) ->
    class HeaderAnalyzer

        shouldParticipate: () ->
            false

        analyze: () ->
            ""

    class BudgetAnalyzer extends HeaderAnalyzer
        constructor: (options) ->
          @options = options

        transfers_by_year: (year) ->
          if this.options.changeGroups?
              return arr = $.grep(this.options.changeGroups.models, (el,i) ->
                  el.attributes.year is year)
          else
              return []

        num_of_transfers_in_year_text: (year) ->
          arr = @transfers_by_year(year)
          if arr.length > 1
              return String(arr.length) + " העברות"
          else
              return "שינויים"

        shouldParticipate: () ->
          @options.budgetCode?

    class CurrentBudgetAnalyzer extends BudgetAnalyzer

        shouldParticipate: () ->
            # make sure currentItem exists - /equivs api can return an empty result
            @options.currentItem?.attributes.net_allocated?

        analyze: () ->
            data = @options.currentItem.toJSON()
            # data.transfers_by_year = transfers_by_year.bind(@)
            data.num_of_transfers_in_year_text = @num_of_transfers_in_year_text.bind(@)

            header__current_budget( data )

    class ChangedThisYearAnalyzer extends BudgetAnalyzer

        shouldParticipate: () ->
            res = false
            # make sure currentItem exists - /equivs api can return an empty result
            if @options.currentItem
                year = @options.currentItem.get('year')
                res = @transfers_by_year(year).length > 0

            return res


        analyze: () ->
            data = this.options.currentItem.toJSON()
            data.num_of_transfers_in_year_text = @num_of_transfers_in_year_text.bind(@)
            header__changed_this_year(data)



    class HeaderView extends Backbone.View

        initialize: (options) ->
            @options = options

            analyzers = [
                new CurrentBudgetAnalyzer({changeGroups: options.changeGroups, currentItem: options.currentItem, budgetCode: options.budgetCode})
                new ChangedThisYearAnalyzer({changeGroups: options.changeGroups, currentItem: options.currentItem, budgetCode: options.budgetCode})
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

    HeaderView
)
