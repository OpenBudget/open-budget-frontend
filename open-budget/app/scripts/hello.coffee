window.format_number = (num,is_shekels) ->
        num_to_str = (x) ->
                if x > 0
                        x = "+"+x
                else
                        x = ""+x
                x=x.substring(0,4)
                if x.indexOf(".") == 3
                        x=x.substring(0,3)
                "&lrm;" + x  + "&rlm;"

        if is_shekels == true
                num = num / 1000

        if not num or num == 0
                "—"
        else if Math.abs(num) < 1000
                num_to_str(num) + " אלף ש״ח "
        else if Math.abs(num) < 1000000
                num_to_str(num / 1000) + " מיליון ש״ח "
        else if Math.abs(num) < 1000000000
                num_to_str(num / 1000000) + " מיליארד ש״ח "
        else
                "—"

window.color_classname = (value) ->
    if value == 0 then ""
    return if value > 0 then "increased" else "decreased"

get_program = (obj,datum,name) ->
        console.log "selected:", obj, datum, name
        console.log "selected2:", $("#search-item").val()
        if datum?
            code = datum.code
            window.location.hash = "#budget/" + code + "/" + window.pageModel.get('year')
            window.location.reload()
        else
            code = $("#search-item").val()
            if code.match(/^[0-9]+$/)
                window.location.hash = "#budget/00" + code + "/" + window.pageModel.get('year')
                window.location.reload()

$( ->
        console.log 'setting up typeahead'
        $("#search-item").typeahead(
                name: 'budgets'
                limit: 20
                engine: Hogan
                template: [ '<p class="item-code">{{code}}</p>'
                            '<p class="item-title">{{title}}</p>' ].join('')
                remote:
                        url: window.pageModel.get('baseURL')+"/api/search/budget/#{pageModel.get('year')}?q=%QUERY&limit=20"
                        dataType: 'jsonp'
                        filter: (l) ->
                                for x in l
                                        x._code = x.code.substring(2)
                                        x.value = x._code
                                l
        )
        $('.typeahead.input-sm').siblings('input.tt-hint').addClass('hint-small');
        $('.typeahead.input-lg').siblings('input.tt-hint').addClass('hint-large');
        $("#search-item").bind('typeahead:selected', get_program )
        $("#search-item").bind('change', get_program )
        $("#search-form").submit( ->
                false
                )
        window.onhashchange = -> window.location.reload()
)
