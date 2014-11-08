$( ->
    $('.spinner-container')
       .html( window.JST.spinner() )
       .toggleClass('spinner-container',false)
)
