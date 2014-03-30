/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

window.AudioContext =
  window.webkitAudioContext ||
  window.mozAudioContext ||
  window.msAudioContext ||
  window.oAudioContext ||
  window.AudioContext;

function AudioParser(dataSize) {

  "use strict";

  var audioContext = new AudioContext();
  var analyser = audioContext.createAnalyser();
  var sourceNode = null;
  var gainNode = null;
  var audioRenderer = null;
  var audioDecodedCallback = null;
  var timePlaybackStarted = 0;

  analyser.smoothingTimeConstant = 0.2;
  analyser.fftSize = dataSize;

  function onDecodeData (buffer) {

    if (!sourceNode) {

      sourceNode = audioContext.createBufferSource();
      gainNode = audioContext.createGainNode();

      sourceNode.loop = false;

      sourceNode.connect(gainNode);
      gainNode.connect(analyser);
      analyser.connect(audioContext.destination);

      gainNode.gain.value = 0.5;
    }

    sourceNode.buffer = buffer;

    if (timePlaybackStarted === 0)
      sourceNode.noteOn(0);

    timePlaybackStarted = Date.now();

    audioDecodedCallback(buffer);

  }

  function onError() {
    alert("Hmm, couldn't parse that file. Try something else?");
  }

  this.getAnalyserAudioData = function (arrayBuffer) {
    analyser.getByteFrequencyData(arrayBuffer);
  };

  this.parseArrayBuffer = function (arrayBuffer, onAudioDataDecoded) {
    audioDecodedCallback = onAudioDataDecoded;
    audioContext.decodeAudioData(arrayBuffer, onDecodeData, onError);
  };

  this.getTime = function() {
    return (Date.now() - timePlaybackStarted) * 0.001;
  };

}

var audioContext = new AudioContext();
