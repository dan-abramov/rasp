document.addEventListener('DOMContentLoaded', function(){
  if (document.getElementById("map")) {
    ymaps.ready(init);
    function init(){
      var myMap = new ymaps.Map("map", {
        center: [56.74258201923115, 37.15819910393005],
        zoom: 13
      });
      var busStationArray = [['Дубна, улица Березняка', [56.763211033373835,37.144266405296484]],
                             ['Улица Мичурина', [56.75130625311628,37.20256463324331]],
                             ['Стадион', [56.755104548238606,37.12879606386732]],
                             ['Площадь Мира', [56.7460098492459,37.193872913554586]],
                             ['банк Возрождение', [56.73452866331205,37.155617206680205]],
                             ['ТЦ "Маяк"', [56.73575303247329,37.15887567232807]],
                             ['Тверская улица', [56.76078624285189,37.13272905214866]]]

      busStationArray.forEach(function(busStation) {
        var placemark = new ymaps.Placemark(busStation[1], {
          hintContent: busStation[0],
          iconCaption: busStation[0],
          clicked: 0
        }, {
          preset: 'islands#circleIcon',
          iconColor: '#3caa3c'
        });

        var from = document.getElementById('route_from');
        var to = document.getElementById('route_to');
        var form_inputs = [from, to]
        window.first_clicked = null
        window.last_clicked = null

        placemark.events
        .add('click', function (e) {
          if (e.get('target')['properties']['_data']['clicked'] == 0) {
            e.get('target')['properties']['_data']['clicked'] = 1

            if (window.last_clicked) {
              window.last_clicked.options.set('iconColor', '#3caa3c');
              window.last_clicked['properties']['_data']['clicked'] = 0
              to.value = ''
            };

            if (!window.first_clicked) {
              window.first_clicked = e.get('target');
            } else if (window.first_clicked) {
              window.last_clicked = e.get('target');
            }

            e.get('target').options.set('iconColor', 'red'); //here changes color of placemark

            var station = e.get('target')['properties']['_data']['hintContent'];

            if (from.value == '') { //name of station appears in form's input
              from.value = station;
              document.getElementById('clear-input-from').setAttribute("style", "display: block");
            } else if (to.value == '') {
              to.value = station;
              document.getElementById('clear-input-to').setAttribute("style", "display: block");
            };

          } else if (e.get('target')['properties']['_data']['clicked'] == 1) { //if it was second click on placemark....
            e.get('target')['properties']['_data']['clicked'] = 0
            e.get('target').options.set('iconColor', '#3caa3c') //...it changed color of placemark backwards....
            var station = e.get('target')['properties']['_data']['hintContent'];


            if (window.first_clicked == e.get('target')) {
              window.first_clicked = window.last_clicked //...last click becomes first click....
              from.value = to.value // ...it moved text from second input to first input.
              to.value = ''
              window.last_clicked = null
            } else if (window.last_clicked == e.get('target')) {
              window.last_clicked = null
            }

            form_inputs.forEach(function(input) { // this itartion controls...
              if (input.value == station) { // ...if placemark on map was unclicked...
                input.value = '' // ...station name will dissappear from input.
              };
            });
          };



        })
        .add('mapchange', function(e) {
          var station = e.get('target')['properties']['_data']['hintContent'];
          form_inputs.forEach(function(input) {
            if (input.value == station) {
              e.get('target').options.set('iconColor', 'red');
              e.get('target')['properties']['_data']['clicked'] = 1;
            }
          });


        });
        myMap.geoObjects.add(placemark);
      });

    };
  };
});
