/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

function Mandelbro() {

  "use strict";

  var DATA_SIZE = 1024;

  var audioParser = new AudioParser(DATA_SIZE, onAudioDataParsed);
  var audioRenderer = new AudioRenderer();
  var audioData = new Uint8Array(DATA_SIZE);
  var audioDuration = 1;
  var audioTime = 0;
  var audioPlaying = false;
  var time = document.getElementById('time');
  var fileName = '';

  var generateProgress = document.getElementById('generate-progress');

  var getDownload = document.getElementById('get-download');

  function onFileRead(evt) {
    audioParser.parseArrayBuffer(evt.target.result);
  }

  function onAudioDataParsed(buffer) {

    audioDuration = buffer.duration;
    audioPlaying = true;

    audioRenderer.clear();
  }

  function updateAndRender() {

    audioParser.getAnalyserAudioData(audioData);
    audioTime = audioParser.getTime() / audioDuration;

    if (audioPlaying) {
      audioRenderer.render(audioData, audioParser.getContextTime());
      time.style.width = (audioTime * 100).toFixed(1) + '%';
    }

    requestAnimFrame(updateAndRender);
  }

  this.setName = function (name) {
    fileName = name;
  };

  this.parse = function (file) {
    var fileReader = new FileReader();
    fileReader.addEventListener('loadend', onFileRead);
    fileReader.readAsArrayBuffer(file);
  };

  requestAnimFrame(updateAndRender);
}
