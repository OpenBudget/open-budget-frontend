console.log "'Allo from CoffeeScript!"

window.format_number = (num,is_shekels) ->
        num_to_str = (x) ->
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
                num_to_str(num) + " אלף ₪ "
        else if Math.abs(num) < 1000000
                num_to_str(num / 1000) + " מיליון ₪ "
        else if Math.abs(num) < 1000000000
                num_to_str(num / 1000000) + " מיליארד ₪ "
        else
                "—"

window.format_percent = (revised,allocated) ->
        if not revised or not allocated or allocated == 0
                return "—"
        num = revised / allocated
        num = (num*100.0)-100
        bold = false
        bold = num > 25 or num < -25
        ret = num.toFixed(2)+"%"
        ret = "&lrm;" + ret  + "&rlm;"
        if bold
                "<strong style='color:red'>"+ret+"</strong>"
        else
                ret

handle_data = (data) ->
        console.log data
        data['titles'] =
                '2': 'תחומי פעולה',
                '3': 'תכניות',
                '4': 'תקנות'

        _.each( $(".template"), (e) ->
                el = $(e)
                template_name = el.attr('data-template')
                template = $("#"+template_name).html()
                console.log 'template',template
                console.log 'data',data
                rendered = _.template(template,data)
                console.log 'rendered',rendered
                el.html( rendered )
                el.css("display","inherit")
                #el.toggleClass("template",false)
        )
        console.log 'activating'
        $(".tablesorter").tablesorter(
                theme:'blue'
                textExtraction: (node)->
                        $(node).attr('data-sortkey')

        )


process_templates = (code,year) ->
        _.each( $(".template"), (e) ->
                el = $(e)
                template_name = el.attr('data-template')
                template = $("#"+template_name).html()
                api_path = el.attr('data-path')
                debug = el.attr('data-debug') != "n"
                extra = el.attr('data-extra')
                pagesize = el.attr('data-pagesize')
                if extra
                        try
                                extra = JSON.parse(extra)
                        catch
                                console.log 'cant parse '+extra
                if pagesize
                        pagesize = parseInt(pagesize)
                console.log "pagesize:"+pagesize
                if api_path
                        console.log api_path
                        api_path = api_path.replace('{code}',"00"+code)
                        api_path = api_path.replace('{code^}',"00"+code.substring(0,code.length-2))
                        api_path = api_path.replace('{code^^}',"00"+code.substring(0,code.length-4))
                        api_path = api_path.replace('{code^^^}',"00"+code.substring(0,code.length-6))
                        api_path = api_path.replace('{year}',year)
                        url = 'http://obudget.org/api/' + api_path
                        render_template = (data) ->
                                data = {'data':data}
                                data.extra = extra
                                if debug then console.log data
                                if debug then console.log template
                                rendered = _.template(template,data)
                                el.html( rendered )
                                el.css("display","inherit")
                                if debug then console.log 'rendered',rendered
                                table = el.find(".tablesorter").tablesorter(
                                        theme:'blue'
                                        textExtraction: (node)->
                                                $(node).attr('data-sortkey')
                                        )
                                if pagesize
                                    table.tablesorterPager({container: el.find(".pager"), size: 10, positionFixed: false})

                        $.get(url, render_template, 'jsonp')

                )

get_program = ->
        program_num = $("#search-item").val()
        console.log "loading new program "+program_num
        window.location.hash = "#"+program_num+"/"+2015

$ ->
        $(".template, .tab-content").css("display","none")
        $(window).hashchange( ->
                $(".tab-content").css("display","none")
                queryString = window.location.hash.substring(1)
                console.log queryString
                queryString = queryString.split("/")
                code = queryString[0]
                year = queryString[1]
                process_templates(code,year)
                #$.get('http://the.open-budget.org.il/report/api/'+queryString, handle_data, 'jsonp')
                location = window.location.pathname + window.location.search + window.location.hash
                window.ga('send', 'pageview', location)
                $(".tab-content").css("display","inherit")
        )
        $("#search-item").typeahead(
                name: 'budgets'
                limit: 20
                engine: Hogan
                template: [ '<p class="item-code">{{_code}}</p>'
                            '<p class="item-title">{{title}}</p>' ].join('')
                remote:
                        url: 'http://www.obudget.org/api/search/full_text?q=%QUERY&limit=20&types=BudgetLine&year=2015'
                        dataType: 'json'
                        filter: (l) ->
                                for x in l
                                        if x.real_code?
                                            code = x.real_code
                                        else
                                            code = x.code.substring(2)
                                        x._code = code
                                        x.value = x._code
                                l
        )
        $('.typeahead.input-sm').siblings('input.tt-hint').addClass('hint-small');
        $('.typeahead.input-lg').siblings('input.tt-hint').addClass('hint-large');
        $("#search-item").on('typeahead:selected', get_program )
        $("#search-item").on('change', get_program )
        $("#new-program .btn").click( get_program )
        $( window ).hashchange()
