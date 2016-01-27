define([
  'backbone',
  'underscore',
  'templates/header__current_budget.html',
  'templates/header__changed_this_year.html'
  ], (Backbone, _, header__current_budget, header__changed_this_year) ->


    # used by templates files
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
        constructor: (model) ->
          @model = model;

        transfers_by_year: (year) ->
          if this.model.changeGroups?
              return arr = $.grep(this.model.changeGroups.models, (el,i) ->
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
          @model.get('budgetCode')?

    class CurrentBudgetAnalyzer extends BudgetAnalyzer

        shouldParticipate: () ->
            # make sure currentItem exists - /equivs api can return an empty result
            @model.get('currentItem')?.attributes.net_allocated?

        analyze: () ->
            data = @model.get('currentItem').toJSON()
            # data.transfers_by_year = transfers_by_year.bind(@)
            data.num_of_transfers_in_year_text = @num_of_transfers_in_year_text.bind(@)

            header__current_budget( data )

    class ChangedThisYearAnalyzer extends BudgetAnalyzer

        shouldParticipate: () ->
            res = false
            # make sure currentItem exists - /equivs api can return an empty result
            if @model.get('currentItem')
                year = @model.get('currentItem').get('year')
                res = @transfers_by_year(year).length > 0

            return res


        analyze: () ->
            data = this.model.get('currentItem').toJSON()
            data.num_of_transfers_in_year_text = @num_of_transfers_in_year_text.bind(@)
            header__changed_this_year(data)



    class HeaderView extends Backbone.View

        initialize: ->
            analyzers = [
                new CurrentBudgetAnalyzer(this.model)
                new ChangedThisYearAnalyzer(this.model)
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
