
class CombinedHistoryPoint extends Backbone.Model

        defaults:
                kind: null
                subkind: ""
                timestamp: null
                value: null
                source: null
                width: 0
                date: null
                last: false

                diff_value: null


class CombinedHistory extends Backbone.Collection

        model: CombinedHistoryPoint

        comparator: 'timestamp'

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @changeGroups = @pageModel.changeGroups
                @budgetHistory = @pageModel.budgetHistory
                @pageModel.on "ready", =>
                    @processChangeLines(@changeGroups.models)
                    @processBudgetHistory(@budgetHistory.models)
                    @postProcess()
                @minValue = @maxValue = @minTime = @maxTime = null

        postProcess: () ->
                last_baseline = null
                baseline = null
                lastPoint = null
                changes = 0
                for point in @models
                        time = point.get('timestamp')
                        point.set('date', new Date(time) )
                        kind = point.get('kind')
                        if kind  == 'approved'
                                last_baseline = original_baseline
                                original_baseline = point.get('value')
                                if baseline != null && changes > 1
                                    point.set('diff_value',original_baseline - baseline)
                                baseline = original_baseline
                                lastPoint = null
                                if last_baseline != null
                                        point.set('diff_yearly', baseline-last_baseline)
                                changes = 0
                        else if kind == 'change'
                                changes += 1
                                if baseline != null
                                        baseline += point.get('diff_value')
                                        point.set('diff_baseline',baseline - original_baseline)
                                        point.set('original_baseline', original_baseline)
                                        point.set('value', baseline)
                                        if lastPoint != null
                                                lastPoint.set('width',time - lastPoint.get('timestamp'))
                                        lastPoint = point
                                else
                                        continue
                        else
                                continue
                        value = point.get('value')
                        if @minValue == null or @minValue > value
                                @minValue = value
                        if @maxValue == null or @maxValue < value
                                @maxValue = value
                        width = point.get('width')
                        if @minTime == null or @minTime > time
                                @minTime = time
                        if @maxTime == null or @maxTime < time + width
                                @maxTime = time + width
                @reset(@models)

        processBudgetHistory: (models) ->
                for m in models
                        value = m.get("net_allocated")
                        if value?
                                point = new CombinedHistoryPoint()
                                point.set("source", m)
                                point.set("kind", "approved")
                                point.set("value", m.get("net_allocated"))
                                startYear = new Date(m.get('year'),0).valueOf()
                                endYear = new Date(m.get('year'),11,31).valueOf()
                                point.set('timestamp',startYear)
                                point.set('width', endYear - startYear)
                                point.set('src','budgetline')
                                @add point

                                # period between start of year and first committee
                                point = new CombinedHistoryPoint()
                                point.set("source",m)
                                point.set('kind','change')
                                point.set('diff_value',0)
                                point.set('timestamp',startYear+1)
                                point.set('width',endYear-startYear-1)
                                point.set('src','budgetline')
                                @add point

                        value = m.get("net_used")
                        if value?
                                point = new CombinedHistoryPoint()
                                point.set("source", m)
                                point.set("kind", "used")
                                point.set("value", m.get("net_used"))
                                startYear = new Date(m.get('year'),11,20).valueOf()
                                endYear = new Date(m.get('year'),11,31).valueOf()
                                point.set('timestamp',startYear)
                                point.set('width', endYear - startYear)
                                point.set('src','budgetline')
                                @add point

        processChangeLines: (models) ->
                changesPerYear = _.groupBy( models, (m) => m.get('year') )
                changesPerYear = _.pairs( changesPerYear )
                changesPerYear = _.sortBy( changesPerYear, (pair) => pair[0] )
                for pair in changesPerYear
                        [year, yearly] = [parseInt(pair[0]), pair[1]]
                        yearly = _.sortBy( yearly, (m) => m.get('timestamp') )
                        yearStart = new Date(year,0).valueOf()
                        yearEnd = new Date(year,11,31).valueOf()
                        actualLen = _.filter(yearly, (m) -> m.getCodeChanges(@pageModel.get("budgetCode")).expense_change != 0).length

                        timestamp = yearStart
                        lastPoint = null
                        for m, i in yearly
                                value = m.getCodeChanges(@pageModel.get("budgetCode")).expense_change
                                if value? and value != 0
                                        point = new CombinedHistoryPoint()
                                        point.set("source",m)
                                        point.set('kind','change')
                                        point.set('diff_value',value)
                                        point.set('subkind',m.getDateType())
                                        date = m.get('timestamp')
                                        diff = date - timestamp
                                        console.log m.get('date'),m.get('timestamp'),diff
                                        timestamp = date
                                        if lastPoint
                                                lastPoint.set('width', diff)
                                        lastPoint = point

                                else
                                        point = new CombinedHistoryPoint()
                                        point.set("source",m)
                                        point.set('kind','change-misc')

                                point.set('timestamp',timestamp)
                                point.set('src', 'changeline')

                                @add point
                        if lastPoint?
                                lastPoint.set('width', yearEnd - timestamp)
                                lastPoint.set('last', true)

$( ->
    if window.pageModel.get('budgetCode')?
        window.combinedHistory = new CombinedHistory([], pageModel: window.pageModel)
)
