require.config({
    baseUrl: ".",
    paths: {
        "hbs": "bower_components/require-handlebars-plugin/hbs",
        "handlebarsRuntime":    "bower_components/require-handlebars-plugin/hbs/handlebars.runtime",
        "twitter":              "//platform.twitter.com/widgets",
        "hasadna-notifications":"//hasadna-notifications.appspot.com/static/hn",
        "jquery":               "bower_components/jquery/jquery",
        "jquery-ui":            "bower_components/jquery-ui/jquery-ui.min",
        "bootstrap":            "bower_components/bootstrap/dist/js/bootstrap",
        "modernizr":            "bower_components/modernizr/modernizr",
        "d3":                   "bower_components/d3/d3",
        "d3-tip":               "bower_components/d3-tip/index",
        "underscore":           "bower_components/underscore/underscore",
        "backbone":             "bower_components/backbone/backbone",
        "bloodhound":           "bower_components/typeahead.js/dist/bloodhound.min",
        "bootstrap-tour":       "bower_components/bootstrap-tour/build/js/bootstrap-tour",
        "pivot":                "bower_components/pivottable/dist/pivot",
        "d3_renderers":         "bower_components/pivottable/dist/d3_renderers",
        "text":                 "bower_components/requirejs-text/text",
        "tpl":                  "bower_components/requirejs-tpl/tpl",
        "vendor/numbro":        "bower_components/numbro/numbro",
        "vendor/moment":        "bower_components/moment/moment",
        "vendor/papaparse":     "bower_components/papaparse/papaparse",
        "vendor/StringView":    "bower_components/stringview/stringview",
        "vendor/bootstrap-select":    "bower_components/bootstrap-select/dist/js/bootstrap-select",
        "ecma_5":               "scripts/interval-query/lib/browser/ecma_5",
        "segment-tree-browser": "scripts/interval-query/lib/browser/segment-tree-browser",
        "team":                 "scripts/team",
        "url_scheme":           "scripts/url_scheme",
        "main_page_tabs":       "scripts/main_page_tabs",
        "models":               "scripts/models",
        "spinner":              "scripts/spinner",
        "combined_history":     "scripts/combined_history",
        "history_widget":       "scripts/history_widget",
        "indepth_widget":       "scripts/indepth_widget",
        "views":                "scripts/views",
        "detailed_history":     "scripts/detailed_history",
        "single_changegroup":   "scripts/single_changegroup",
        "breadcrumb_header":    "scripts/breadcrumb_header",
        "analysis_header":      "scripts/analysis_header",
        "bubble_chart":         "scripts/bubble_chart",
        "main_page_vis":        "scripts/main_page_vis",
        "support_list":         "scripts/support_list",
        "support_pivot_table":  "scripts/support_pivot_table",
        "spending_list":        "scripts/spending_list",
        "spending_pivot_table": "scripts/spending_pivot_table",
        "searchbar":            "scripts/searchbar",
        "subscribe":            "scripts/subscribe",
        "hello":                "scripts/hello",
        "training":             "scripts/training",
        "budget_view":           "scripts/budget_view",
        "Hasadna/oBudget":       "scripts/Hasadna/oBudget"
    },
    shim: {
        pivot: {
            deps: ['jquery', 'jquery-ui']
        }
        bootstrap: {
            deps: ['jquery', 'jquery-ui']
        },
        underscore: {
            exports: '_'
        },
        backbone: {
            deps: ["underscore", "jquery"],
            exports: "Backone"
        },
        ecma_5: {
            exports: "Array.prototype.forEach"
        },
        "twitter": {
            exports: "twttr"
        },
        "segment-tree-browser": {
            exports: "segmentTree"
        },
        "bloodhound": {
            deps: ['jquery'],
            exports: "Bloodhound"
        },
        "bootstrap-tour": {
            deps: ['jquery'],
            exports: "Tour"
        },
        "hasadna-notifications": {
            exports: "hn"
        },
        "modernizr": {
            exports: "Modernizr"
        },
        "vendor/StringView": {
          exports: "StringView"
        }
    },

    hbs: {
      handlebarsPath: 'handlebarsRuntime',
      helperDirectory: 'Hasadna/oBudget/Misc/handlebarsHelpers/'
    }
})
