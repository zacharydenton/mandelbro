/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

function MusicDNA() {

  "use strict";

  var DATA_SIZE = 1024;

  var audioParser = new AudioParser(DATA_SIZE);
  var audioRenderer = new AudioRenderer();
  var audioData = new Uint8Array(DATA_SIZE);
  var audioDuration = 1;
  var audioTime = 0;
  var audioPlaying = false;
  var time = document.getElementById('time');

  function onFileRead(event) {
    audioParser.parseArrayBuffer(event.target.result, onAudioDataParsed);
  }

  function onAudioDataParsed(buffer) {

    audioDuration = buffer.duration;
    audioPlaying = true;

    audioRenderer.clear();
  }

  function updateAndRender() {

    audioParser.getAnalyserAudioData(audioData);
    audioTime = audioParser.getTime() / audioDuration;

    time.style.width = (audioTime * 100).toFixed(1) + '%';

    if (audioPlaying)
      audioRenderer.render(audioData, audioTime);

    if (!audioPlaying || audioTime <= 1) {
      requestAnimFrame(updateAndRender);
    }
  }

  this.parse = function (file) {
    var fileReader = new FileReader();
    fileReader.addEventListener('loadend', onFileRead);
    fileReader.readAsArrayBuffer(file);
  };

  requestAnimFrame(updateAndRender);
}
