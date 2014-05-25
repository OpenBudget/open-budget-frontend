console.log('\'Allo \'Allo!');
$( function() {
    $.get('http://the.open-budget.org.il/api/sysprop/rss_items', function (data) {
        var rss_items = data.value;
        console.log("got 1");
        $.get('http://the.open-budget.org.il/api/sysprop/rss_title', function (data) {
            var feed_title = data.value;
            console.log("got 1");
            $.get('templates/email_item_template.jinja.html', function(data) {
                var item_template = data;
                console.log("got 2");
                var rendered_items = [];
                for ( var _item in rss_items ) {
                    var item = rss_items[_item];
                    rendered_item = jinja.render(item_template,item);
                    rendered_items.push({
                        description: rendered_item,
                        title: item.title,
                        index: parseInt(_item)+1
                    });
                }
                $.get("templates/email_template.mustache.html", function(data) {
                    var feed_template = data;
                    var template_data = {
                        entries: rendered_items,
                        feed: {
                            'title': feed_title
                        }
                    };
                    var full = Mustache.render(feed_template,template_data);
                    document.write(full);
                },"html");
            }, "html");
        }, "jsonp");
    }, "jsonp");
});
