window.num_to_str = (x) ->
            if x > 0
                    x = "+"+x
            else
                    x = ""+x
            x=x.substring(0,4)
            if x.indexOf(".") == 3
                    x=x.substring(0,3)
            "&lrm;" + x  + "&rlm;"


window.format_number = (num,is_shekels) ->

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

window.format_full_number = (num) ->
        if not num or num == 0
                "—"
        num = num.toString()
        num = num.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        "&lrm;" + num  + "&rlm;"

window.color_classname = (value) ->
    if value == 0 then ""
    return if value > 0 then "increased" else "decreased"

window.changeClass = (orig_value,revised_value) ->
    if revised_value > 1.5*orig_value       then "increased"
    else if revised_value > 1.2*orig_value  then "increased_6"
    else if revised_value > 1.02*orig_value then "increased_3"
    else if revised_value > 0.98*orig_value then "unchanged"
    else if revised_value > 0.8*orig_value  then "decreased_3"
    else if revised_value > 0.5*orig_value  then "decreased_6"
    else "decreased"

window.linkToBudget = (code,year) -> "#budget/#{code}/#{year}"
window.linkToTransfer = (code,year) -> "#transfer/#{code}/#{year}"

$( ->
        window.onhashchange = -> window.location.reload()
)
