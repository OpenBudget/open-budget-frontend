define [
  "underscore",
  "Hasadna/oBudget/Pages/Exemptions/parentMinistriesVariants",
  "vendor/papaparse",
  "vendor/StringView",
  "vendor/moment"
], (_, parentMinistriesVariants, papaparse, StringView, moment) ->
  dataHelpers =

    composeExemptionsSortFunc: (controlsValues) ->
      return (exemption1, exemption2) ->
        ret = true

        switch controlsValues.orderBy
          when "total_flags"
            if !exemption1.flags
              exemption1.flags =
                total_flags: 0

            if !exemption2.flags
              exemption2.flags =
                total_flags: 0

          when "date"
            ret = (exemption1.last_update_date.getTime() or 0) > (exemption2.last_update_date.getTime() or 0)
          when "volume"
            ret = exemption1.volume > exemption2.volume
          else
            ret = exemption1.flags.total_flags > exemption2.flags.total_flags

        if ret
         -1 * controlsValues.orderByDirection
        else
          1 * controlsValues.orderByDirection

    composeExemptionsFilterFunc: (controlsValues, ministriesAliasesIndex) ->
      filterByMinistry = false

      if (controlsValues.ministry.length > 0)
        # build list of possible ministreis branches
        localIndex = _.pick ministriesAliasesIndex, controlsValues.ministry
        localIndex = _.values localIndex
        localIndex = _.flatten localIndex
        filterByMinistry = true

      return (exemption) ->
        timeFrameStart = moment().subtract(controlsValues.timeFrame, 'days').valueOf()

        if (!(exemption.get('last_update_date').getTime() > timeFrameStart))
          return false

        if (filterByMinistry && !(localIndex.indexOf(exemption.get('publisher')) > -1))
          return false

        # textSearchFields = [

        # ]

        # free text here, by what fields ?
        # ret = ret and !controlsValues.freeText or @freeTextFilter controlsValues.freeText, exemption

        return true

    generateAliasesIndex: (ministriesWithDepartments) ->
      aliasesIndex = _.object(_.keys(parentMinistriesVariants), [])

      _.each(aliasesIndex, (stub, ministry) ->
        aliasesIndex[ministry] = [ministry]

        _.each(ministriesWithDepartments, (rawMinistry, i) ->
          parentMinistriesVariants[ministry].forEach (ministryVariant) ->
            if rawMinistry.indexOf(ministryVariant) > -1
              aliasesIndex[ministry].push rawMinistry
              # mark this entry as matched
              ministriesWithDepartments[i] = '---matched---'
        )
      )

      # if there is records in ministriesWithDepartments that don't match any parentMinistriesVariants
      # Add them as separate entries in the index
      ministriesWithDepartments = ministriesWithDepartments.filter (rawMinistry)->
        rawMinistry != '---matched---'

      _.each(ministriesWithDepartments, (rawMinistry, key) ->
        aliasesIndex[rawMinistry] = [rawMinistry]
      )

      aliasesIndex

    generateAliasesMap: (ministriesWithDepartments) ->
      aliasesMap = _.object ministriesWithDepartments, ministriesWithDepartments

      _.mapObject aliasesMap, dataHelpers.getMinistryForMinistryVariant

    getMinistryForMinistryVariant: (ministryVariant) ->
      matched = null

      _.each parentMinistriesVariants, (variantsArray, ministry) ->
        if (matched)
          return

        variantsArray.forEach (variantFragment) ->
          if (ministryVariant.indexOf variantFragment) > -1
            matched = ministry

      if !matched
        matched = ministryVariant

      matched

    getExemptionsExportUrl: (exemptions) ->
      exs = exemptions.map (e) ->
        e = _.omit(e, ['flags'])

        _.mapObject(e, (f) ->
          if f instanceof Date
            moment(f).format()
          else
            f
        )

      strView = new StringView(papaparse.unparse(exs), "UTF-16")
      url = URL.createObjectURL(new Blob([strView.buffer], { "type": "text/csv;charset=UTF-16" }))

    getSupportsExportUrl: (supports) ->
      strView = new StringView(papaparse.unparse(supports), "UTF-16")
      url = URL.createObjectURL(new Blob([strView.buffer], { "type": "text/csv;charset=UTF-16" }))

    extractRawMinistriesWithDepartmentsFromExemptions: (exemptions)->

  dataHelpers
