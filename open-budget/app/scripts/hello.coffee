console.log "'Allo from CoffeeScript!"

get_program = ->
        window.pageModel.set('budgetCode', $("#search-item").val())

$( ->
        console.log 'setting up typeahead'
        $("#search-item").typeahead(
                name: 'budgets'
                limit: 20
                engine: Hogan
                template: [ '<p class="item-code">{{code}}</p>'
                            '<p class="item-title">{{title}}</p>' ].join('')
                remote:
                        url: window.pageModel.get('baseURL')+'/api/search/budget/2013?q=%QUERY&limit=20'
                        dataType: 'jsonp'
                        filter: (l) ->
                                for x in l
                                        x._code = x.code.substring(2)
                                        x.value = x._code
                                l
        )
        $('.typeahead.input-sm').siblings('input.tt-hint').addClass('hint-small');
        $('.typeahead.input-lg').siblings('input.tt-hint').addClass('hint-large');
        $("#search-item").on('typeahead:selected', get_program )
        $("#search-item").on('change', get_program )

)