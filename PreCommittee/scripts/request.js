$( document ).ready(function() {

	initPopop();

	$('#requestHeader h4').text(formatDate($('#requestHeader h4').text()));

	$('#pagesCarousel .item').first().addClass('active');
	$('.carousel').carousel({
		interval: false
	});

	populateTransfers($('.transfer_details ul'), getPages(data));

	// DOM events
	$('.transfer_details .add_row').click(function(e) {
		var list = $(this).parents('.transfer_details').find('ul');
		addRow(list, getEmptyTransfer());
	});

	$('.transfer_details ul').delegate('li .del_row', 'click', function(e) {
		var row = $(this).parents('li');
		row.animate({height:'toggle'}, 100, function() { row.remove(); });			
	});

	$('.btns_container input[name="btnClear"]').click(function(e) {
		var container = $(this).parents('.transfer_details');
		container.find('input[type="text"]').val('');
		container.find("li.transfer_row:not(:first)").remove();		
	});

	$('.btns_container input[name="btnSave"]').click(function(e) {
		var container = $(this).parents('.item');
		var data = {
			pageId: container.find('.transfer_details').data('id'),
			pageNumber: container.find('input[name="subRequestNum"]').val(),
			image: container.find('.img_container img').attr('src'),
			transfers: []
		};
		
		$.each(container.find('li.transfer_row'), function(index, li) {
			var id = $(li).find('input[name="articleId"]').val();
			var transferAmount = $(li).find('input[name="amount"]').val();
			if (id && transferAmount)
				data.transfers.push({
					articleId: id,
					amount: transferAmount
			});
		});

		$.post( "/page", data, function(result) {
  			if (result.success)
  				popup('המידע נשמר', 'הודעה');
		});
	});
});

function formatDate(ticks) {

	var t = parseInt(ticks);
	var date = new Date(t);		
	return date.getDate() + '.' + (date.getMonth() + 1) + '.' + date.getFullYear();
}

function addRow(listElm, data) {

	listElm.grow({
  		templateURL: 'templates/li_transfer.html',
  		cache: true,
  		animation: 'slide',
  		speed: 50
	});

	listElm.grow('append', data);
}

function getPages(str) {
	return JSON.parse(data.replace(/'/g,"\"").replace(/None/g,"null"));
}

function getEmptyTransfer(str) {
	return {articleId:'', amount:''};
}

function populateTransfers(listElements, pages) {
	listElements.grow({
		templateURL: 'templates/li_transfer.html',
		cache: true,
		animation: 'slide',
		speed: 10
	});

	var len = pages.length;
	for (var i = 0; i < len; i++) {
		var id = pages[i].pageId;
		var list = $(".transfer_details[data-id='" + id + "']").find('ul');
		var transfers = pages[i].transfers || [getEmptyTransfer()];
		for (var j = 0; j < transfers.length; j++) {
			list.grow('append', transfers[j])
		};
	}
}