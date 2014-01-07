
// var modal = {};

var initPopop = function(modalId) {	
	$('#popupDialog').modal({
		show: false
	});
}

var popup = function(message, title, type) {	
	switch (type) {
		case 'confirm':
		break;
		default:
		break;
	}

	
	$('.body-content').text(message);
	
	if (title) {
		$('.modal-title').text(title);
		$('.modal-header').show(1);
	} else {
		$('.modal-header').hide(1);
	}	

	$('#popupDialog').modal('show');
}