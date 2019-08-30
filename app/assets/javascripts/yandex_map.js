ymaps.ready(init);
function init(){
    var myMap = new ymaps.Map("map", {
        center: [56.74258201923115, 37.15819910393005],
        zoom: 14
    });

    var busStationArray = [['Дубна, улица Березняка', [56.74258201923115, 37.15819910393005]],
                           ['Улица Мичурина', [56.73641333762985,37.16295759773609]]]

    busStationArray.forEach(function(busStation) {
      var placemark = new ymaps.Placemark(busStation[1], {
            // balloonContent: busStation[0]
            hintContent: busStation[0]
      }, {
            preset: 'islands#circleIcon',
            iconColor: '#3caa3c'
      });

      var clicked = 0;
      var from = document.getElementById('route_from');
      var to = document.getElementById('route_to');
      var form_inputs = [from, to]

      placemark.events
        .add('click', function (e) {
          if (clicked == 0) {
            clicked ++;
            e.get('target').options.set('iconColor', 'blue');

            var station = e.get('target')['properties']['_data']['hintContent'];

            if (from.value == '') {
              from.value = station;
            } else if (to.value == '') {
              to.value = station;
            };
          } else if (clicked == 1) {
            clicked = 0
            e.get('target').options.set('iconColor', '#3caa3c')
            var station = e.get('target')['properties']['_data']['hintContent'];

            form_inputs.forEach(function(input) {
              if (input.value == station) {
                input.value = ''
              };
            });
          };
        })
        .add('mapchange', function(e) {
          var station = e.get('target')['properties']['_data']['hintContent'];
          form_inputs.forEach(function(input) {
            if (input.value == station) {
              e.get('target').options.set('iconColor', 'blue');
              clicked = 1;
            }
          });
        });
      myMap.geoObjects.add(placemark);
    });

};
