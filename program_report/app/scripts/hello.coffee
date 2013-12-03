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

        if num == 0
                "—"
        else if num < 1000
                num_to_str(num) + " אלף ש״ח "
        else if num < 1000000
                num_to_str(num / 1000) + " מיליון ש״ח "
        else if num < 1000000000
                num_to_str(num / 1000000) + " מיליארד ש״ח "
        else
                "—"

handle_data = (data) ->
        console.log data
        data['titles'] =
                '2': 'תחומי פעולה',
                '3': 'תכניות',
                '4': 'תקנות'
        #for i in [0..2]
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

get_program = ->
        program_num = $("#new-program input").val()
        console.log "loading new program "+program_num
        window.location.hash = "#00"+program_num+"/"+2013

$ ->
        $(".template, .tab-content").css("display","none")
        $(window).hashchange( ->
                queryString = window.location.hash.substring(1)
                console.log queryString
                $.get('http://the.open-budget.org.il/report/api/'+queryString, handle_data, 'jsonp')
                location = window.location.pathname + window.location.search + window.location.hash
                window.ga('send', 'pageview', location)
        )
        $(".tab-content").css("display","inherit")
        $("#new-program input").change( get_program )
        $("#new-program .btn").click( get_program )
        $( window ).hashchange()
