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
	//     console.log(window.first_station)
	//     var save_first_clicked = window.first_station;
	//     console.log(save_first_clicked)
	//     window.first_station = window.second_station
	//     window.second_station = save_first_clicked
	//   }
	//
	// }, false);

	document.getElementById('clear-input-from').addEventListener('click', function (e) {
    document.getElementById('route_from').value = '';
		window.first_station['properties']['_data']['clicked'] = 0;
		window.first_station.options.set('iconColor', '#3caa3c');
		window.first_station = null;
		document.getElementById('clear-input-from').setAttribute('style', 'display: none');
	});

	document.getElementById('clear-input-to').addEventListener('click', function (e) {
    document.getElementById('route_to').value = '';
		window.second_station['properties']['_data']['clicked'] = 0;
		window.second_station.options.set('iconColor', '#3caa3c');
		window.second_station = null;
		document.getElementById('clear-input-to').setAttribute('style', 'display: none');
	});
});
