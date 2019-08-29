ymaps.ready(init);
function init(){
    var myMap = new ymaps.Map("map", {
        center: [56.74258201923115, 37.15819910393005],
        zoom: 13
    });

    var busStationArray = [['Остановка одна', [56.74258201923115, 37.15819910393005]],
                           ['Остановка другая', [56.73641333762985,37.16295759773609]]]

    busStationArray.forEach(function(busStation) {
      var placemark = new ymaps.Placemark(busStation[1], {
            // balloonContent: busStation[0]
            hintContent: busStation[0]
      }, {
            preset: 'islands#circleIcon',
            iconColor: '#3caa3c'
      })

      var clicked = 0

      placemark.events.add('click', function (e) {
        if (clicked == 0) {
          clicked ++
          e.get('target').options.set('iconColor', 'blue')
          var from = document.getElementById('route_from');
          var to = document.getElementById('route_to');

          if (from.value == '') {
            from.value = e.get('target')['properties']['_data']['hintContent'];
          } else if (to.value == '') {
            to.value = e.get('target')['properties']['_data']['hintContent'];
          }
        } else if (clicked == 1) {
          clicked = 0
          e.get('target').options.set('iconColor', '#3caa3c')
        }


      });

      myMap.geoObjects.add(placemark);
    });

};
