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
  var gainNode = audioContext.createGainNode();
  var sourceNode = null;
  var audioRenderer = null;
  var audioDecodedCallback = null;
  var timePlaybackStarted = 0;

  analyser.smoothingTimeConstant = 0.2;
  analyser.fftSize = dataSize;

  gainNode.gain.value = 0.5;

  function onDecodeData (buffer) {

    // Kill any existing audio
    if (sourceNode) {
      if (sourceNode.playbackState === sourceNode.PLAYING_STATE)
        sourceNode.stop();

      sourceNode.disconnect(gainNode);
      sourceNode = null;
    }

    // Make a new source
    if (!sourceNode) {

      sourceNode = audioContext.createBufferSource();
      sourceNode.loop = false;

      sourceNode.connect(gainNode);
      gainNode.connect(analyser);
      analyser.connect(audioContext.destination);
    }

    // Set it up and play it
    sourceNode.buffer = buffer;
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
