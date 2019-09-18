document.addEventListener('click', function (event) {

	// If the clicked element doesn't have the right selector, bail
	if (event.target.matches('.fa-exchange')) {
    var from = document.getElementById('route_from');
    var to = document.getElementById('route_to');

    var save_from_value = from.value

    from.value = to.value
    to.value = save_from_value
    console.log(window.first_clicked)
    var save_first_clicked = window.first_clicked;
    console.log(save_first_clicked)
    window.first_clicked = window.last_clicked
    window.last_clicked = save_first_clicked
  }

}, false);
