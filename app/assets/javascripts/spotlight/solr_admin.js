var timeout = 2000;
var disabledClass = 'disabled';
var timeoutID;
var progressBar;
var statusText;
var actions;

Spotlight.onLoad(function(){
  addSolrAdminRefresh();
});

function addSolrAdminRefresh(){
  progressBar = $("#solr_progress");
  statusText = $("#solr_status");
  actions = $('.solr-action');
  if (statusText.text() !== 'idle') {
    actions.addClass(disabledClass);
  }
  actions.click(function() {
    actions.addClass(disabledClass);
  })
  if (progressBar.length) {
    timeoutID = window.setTimeout(getSolrStatus, timeout);
  }
}

function getSolrStatus(){
  $.get(location.href + '/status', function(data) {
    if (data.status !== 'idle') {
      var total = progressBar.attr('aria-valuemax');
      var percentage = Math.round(data.completed/total*100);
      progressBar
        .css('width', percentage + '%')
        .text(percentage + '%')
        .attr('aria-valuenow', data.completed);
      timeoutID = window.setTimeout(getSolrStatus, timeout);
    } else {
      progressBar
        .css('width', '0%')
        .text('0%')
        .attr('aria-valuenow', 0)
        .attr('aria-valuemin', 0)
        .attr('aria-valuemax', 0);
      statusText.text(data.status);
      actions.removeClass(disabledClass);
    }
  });
}

