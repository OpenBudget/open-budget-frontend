
class WidgetDataPoint extends Backbone.Model

        defaults:
                kind: null
                timestamp: null
                value: null
                source: null
                width: 0
                

class WidgetData extends Backbone.Collection

        model: WidgetDataPoint

        comparator: 'timestamp'

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @changeLines = @pageModel.changeLines
                @budgetHistory = @pageModel.budgetHistory
                @changeLines.on "reset", => @processChangeLines(@changeLines.models)
                @budgetHistory.on "reset", => @processBudgetHistory(@budgetHistory.models)
                @minValue = @maxValue = @minTime = @maxTime = null
                @gotAllEvents = 2

        postProcess: () ->
                console.log 'postProcess'
                if @gotAllEvents > 0
                        return
                baseline = null
                for point in @models
                        kind = point.get('kind')
                        if kind  == 'approved'
                                baseline = point.get('value')
                        else if kind == 'change'
                                if baseline != null
                                        baseline += point.get('diff-value')
                                        point.set('value', baseline)
                                else
                                        continue
                        else
                                continue
                        value = point.get('value')
                        if @minValue == null or @minValue > value
                                @minValue = value
                        if @maxValue == null or @maxValue < value
                                @maxValue = value
                        time = point.get('timestamp')
                        width = point.get('width')
                        if @minTime == null or @minTime > time
                                @minTime = time
                        if @maxTime == null or @maxTime < time + width
                                @maxTime = time + width
                @reset(@models)

        processBudgetHistory: (models) ->
                console.log 'processBudgetHistory'
                @remove(@where(kind: 'approved'))
                @gotAllEvents -= 1

                for m in models
                        point = new WidgetDataPoint()
                        point.set("source", m)
                        point.set("kind", "approved")
                        value = m.get("net_allocated")
                        if value?
                                point.set("value", m.get("net_allocated"))
                                startYear = new Date(m.get('year'),0).valueOf()
                                endYear = new Date(m.get('year'),11,31).valueOf()
                                point.set('timestamp',startYear)
                                point.set('width', endYear - startYear)
                                @add point
                @postProcess()

        processChangeLines: (models) ->
                console.log 'processChangeLines'
                @remove(@where(kind: 'change'))
                @gotAllEvents -= 1

                changesPerYear = _.groupBy( models, (m) => m.get('year') )
                changesPerYear = _.pairs( changesPerYear )
                changesPerYear = _.sortBy( changesPerYear, (pair) => pair[0] )
                for pair in changesPerYear
                        [year, yearly] = [parseInt(pair[0]), pair[1]]
                        yearly = _.sortBy( yearly, (m) => m.get('req_code') )
                        yearStart = new Date(year,0).valueOf()
                        yearEnd = new Date(year,11,31).valueOf()
                        actualLen = _.filter(yearly, (m) -> m.get('net_expense_diff')? and m.get('net_expense_diff') != 0).length
                        
                        diff = (yearEnd - yearStart) / (actualLen+1)

                        point = new WidgetDataPoint()
                        point.set("source","dummy")
                        point.set('kind','change')
                        point.set('diff-value',0)
                        point.set('timestamp',yearStart+1)
                        point.set('width', diff)
                        @add point

                        timestamp = yearStart
                        for m, i in yearly
                                value = m.get('net_expense_diff')
                                if value? and value != 0
                                        point = new WidgetDataPoint()
                                        point.set("source",m)
                                        point.set('kind','change')
                                        point.set('diff-value',value)
                                        timestamp += diff
                                
                                else
                                        point = new WidgetDataPoint()
                                        point.set("source",m)
                                        point.set('kind','change-misc')
                                
                                point.set('timestamp',timestamp)
                                point.set('width', diff)

                                @add point
                @postProcess()


$( ->
        console.log "Yo Yo Yo"
        window.widgetData = new WidgetData([], pageModel: window.pageModel)
)
