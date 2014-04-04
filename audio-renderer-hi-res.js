/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

function AudioRendererHiRes(size, onRenderedCallback) {
  "use strict";

  var generateProgressBar = document.getElementById('generate-bar');
  var STEP = 1000;
  var TAU = Math.PI * 2;

  var width = 1;
  var height = 1;

  switch (size) {
    case 1: // normal
      width = 1920;
      height = 1280;
      break;

    case 2: // large
      width = 9000;
      height = 6000;
      break;

    case 3: // enormous
      width = 16000;
      height = 12000;
      break;
  }

  var renderData = null;
  var start = 0;
  var end = 0;
  var onRendered = onRenderedCallback;
  var canvas = null;
  var ctx = null;
  var midX = width * 0.5;
  var midY = height * 0.5;

  this.render = function(newRenderData) {

    var ratio = 1;
    var maxRenderDataSize = newRenderData.radius * 2;
    var minRenderDimensions = Math.min(width, height);

    renderData = newRenderData;

    canvas = document.createElement('canvas');
    ctx = canvas.getContext('2d');

    canvas.width = width;
    canvas.height = height;

    ctx.fillStyle = '#111';
    ctx.fillRect(0, 0, width, height);
    ctx.globalCompositeOperation = "lighter";

    // We want to keep things roughly in proportion here,
    // so we should scale up as much as we can... but no more, we don't
    // want to be greedy. People would talk.
    ratio = minRenderDimensions / maxRenderDataSize;

    ctx.translate(midX, midY);
    ctx.scale(ratio, ratio);

    start = 0;
    end = Math.min(end + STEP, renderData.values.length);

    requestAnimFrame(renderPortion);

  };

  function renderPortion() {

    var renderVals;

    // If we aren't going to paint anything else
    // bake out an image and send it back
    if (end - start === 0) {
      onRendered(canvas.toDataURL("image/png"));
      canvas = null;
      ctx = null;
      return;
    }

    for (var i = start; i < end; i++) {

      renderVals = renderData.values[i];

      ctx.globalAlpha = renderVals.alpha;
      ctx.fillStyle = 'hsl(' + renderVals.color + ', 80%, 50%)';
      ctx.beginPath();
      ctx.arc(
        renderVals.x,
        renderVals.y,
        renderVals.size, 0, TAU, false);
      ctx.closePath();
      ctx.fill();
    }

    generateProgressBar.style.width =
        ((end / renderData.values.length) * 100).toFixed(1) + '%';

    start = end;
    end = Math.min(end + STEP, renderData.values.length);

    requestAnimFrame(renderPortion);
  }
}
