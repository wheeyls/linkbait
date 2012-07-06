(function () {
  "use strict";

  function setupGoogleCharts() {
    var def = $.Deferred();

    google.load("visualization", "1", {packages:["corechart"]});
    google.setOnLoadCallback(function () {
      def.resolve(true);
    });

    return def;
  }

  function getChartData() {
    return $.get('/results', null);
  }

  $.when(getChartData(), setupGoogleCharts())
  .then(function (data) {
    var table = google.visualization.arrayToDataTable(data[0]),
        chart = new google.visualization.BarChart(document.getElementById('chart-div')),
        options = {
          title: 'How Visitors Said they Felt About the Link That Got Them Here',
          vAxis: {title: 'Emotion',  titleTextStyle: {color: 'red'}}
        };

    chart.draw(table, options);
  });

  $('.btn').button();

  $('.voting .btn').on('click', function () {
    var choiceId = $(this).data('vote');
    $('.opt').val(false);
    $('#' + choiceId).val(true);
    $('.survey-form').submit();
  });

  $('.survey-form').submit(function () {
    $.post('/vote', $(this).serialize());

    return false;
  });
}());
