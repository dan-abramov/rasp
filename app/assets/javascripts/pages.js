document.addEventListener('DOMContentLoaded', () => {

  function checkInputs() {
    from = document.getElementById('route_from')
    to = document.getElementById('route_to')
    if (from.value != '' && to.value != '') {
      document.getElementById('form-find-button').disabled = false;
    } else {
      document.getElementById('form-find-button').disabled = true;
    };
  };
  let timerId = setInterval(() => checkInputs(), 500);
});
