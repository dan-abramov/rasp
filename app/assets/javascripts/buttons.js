document.addEventListener('DOMContentLoaded', () => {
	// document.addEventListener('click', function (event) {
	//
	// 	if (event.target.matches('.fa-exchange')) {
	//     var from = document.getElementById('route_from');
	//     var to = document.getElementById('route_to');
	//
	//     var save_from_value = from.value
	//
	//     from.value = to.value
	//     to.value = save_from_value
	//     console.log(window.first_clicked)
	//     var save_first_clicked = window.first_clicked;
	//     console.log(save_first_clicked)
	//     window.first_clicked = window.last_clicked
	//     window.last_clicked = save_first_clicked
	//   }
	//
	// }, false);

	document.getElementById('clear-input-from').addEventListener('click', function (e) {
    document.getElementById('route_from').value = '';
		window.first_clicked['properties']['_data']['clicked'] = 0;
		window.first_clicked.options.set('iconColor', '#3caa3c');
		window.first_clicked = null;
		document.getElementById('clear-input-from').setAttribute('style', 'display: none');
	});

	document.getElementById('clear-input-to').addEventListener('click', function (e) {
    document.getElementById('route_to').value = '';
		window.last_clicked['properties']['_data']['clicked'] = 0;
		window.last_clicked.options.set('iconColor', '#3caa3c');
		window.last_clicked = null;
		document.getElementById('clear-input-to').setAttribute('style', 'display: none');
	});
});
