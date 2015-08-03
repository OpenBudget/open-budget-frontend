define(['jquery'], ($) ->
    window.num_to_str = (x,positive_plus=true,includeLRM=true) ->
                if x > 0 and positive_plus
                        x = "+"+x
                else
                        x = ""+x
                x=x.substring(0,4)
                if x.indexOf(".") == 3
                        x=x.substring(0,3)
                if includeLRM then "&lrm;" + x  + "&rlm;" else x


    window.format_number = (num,is_shekels=false,positive_plus=true,includeLRM=true) ->

            if is_shekels == true
                    num = num / 1000

            if not num or num == 0
                    "—"
            else if Math.abs(num) < 1000
                    num_to_str(num,positive_plus,includeLRM) + " אלף ₪ "
            else if Math.abs(num) < 1000000
                    num_to_str(num / 1000,positive_plus,includeLRM) + " מיליון ₪ "
            else if Math.abs(num) < 1000000000
                    num_to_str(num / 1000000,positive_plus,includeLRM) + " מיליארד ₪ "
            else
                    "—"

    window.format_date_diff = (diff) ->
            diff_in_days = Math.floor( diff / 86400000);
            return (diff_in_days / 31).toFixed(1) + " חודשים"

    window.number_with_commas = (num) ->
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");


    window.format_full_number = (num) ->
            if not num or num == 0
                    "—"
            num = num.toString()
            num = num.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
            "&lrm;" + num  + "&rlm;"

    window.number_plus_minus = (value) ->
        sign = ""
        if value > 0
          sign = "+"
        else if value < 0
          sign = "-"
        return sign

    window.color_classname = (value) ->
        if value == 0 then ""
        return if value > 0 then "increased" else "decreased"

    window.changeClassThreshold = [
        {minRatio: 3,       maxRatio: Infinity,  class: "increased_d", legend: "min"},
        {minRatio: 1.5,     maxRatio: 3,         class: "increased_c", legend: "min"},
        {minRatio: 1.2,     maxRatio: 1.5,       class: "increased_b", legend: "min"},
        {minRatio: 1,       maxRatio: 1.2,       class: "increased_a", legend: "min"},
        {minRatio: 1,       maxRatio: 1,         class: "unchanged",   legend: "center"},
        {minRatio: 0.8,     maxRatio: 1,         class: "decreased_a", legend: "max"},
        {minRatio: 0.5,     maxRatio: 0.8,       class: "decreased_b", legend: "max"},
        {minRatio: 0.1,     maxRatio: 0.5,       class: "decreased_c", legend: "max"},
        {minRatio: -1,      maxRatio: 0.1,       class: "decreased_d", legend: "max"},
    ]

    window.changeClass = (orig_value,revised_value) ->
        threshold = revised_value/orig_value
        for changeClass in window.changeClassThreshold
            if  threshold >= changeClass.minRatio and threshold <= changeClass.maxRatio
                return changeClass.class

    $('#glossaryModal').on('show.bs.modal', (event) ->
          console.log "glossaryModal open"
          modal = $(this)
          modal.find('.modal-body').html('<iframe class="scribd_iframe_embed" src="https://www.scribd.com/embeds/248411719/content?start_page=1&view_mode=scroll&show_recommendations=false" data-auto-height="true" data-aspect-ratio="undefined" scrolling="no" id="doc_97331" width="100%" height="600" frameborder="0">
          </iframe>')
    )
)
