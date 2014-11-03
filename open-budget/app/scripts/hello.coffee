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
    if value == 0 then ""
    return if value > 0 then "+" else "-"

window.color_classname = (value) ->
    if value == 0 then ""
    return if value > 0 then "increased" else "decreased"

window.changeClass = (orig_value,revised_value) ->
    if      revised_value > 3*orig_value    then "increased_d"
    else if revised_value > 1.5*orig_value  then "increased_c"
    else if revised_value > 1.2*orig_value  then "increased_b"
    else if revised_value > orig_value      then "increased_a"
    else if revised_value < 0.1*orig_value  then "decreased_d"
    else if revised_value < 0.5*orig_value  then "decreased_c"
    else if revised_value < 0.8*orig_value  then "decreased_b"
    else if revised_value < orig_value      then "decreased_a"
    else "unchanged"

window.linkToBudget = (code,year) -> "#budget/#{code}/#{year}"
window.linkToTransfer = (code,year) -> "#transfer/#{code}/#{year}"

$( ->
        window.onhashchange = -> window.location.reload()
)
