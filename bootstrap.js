/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

window.requestAnimFrame =
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.msRequestAnimationFrame ||
  window.oRequestAnimationFrame ||
  window.requestAnimationFrame;

(function() {

  var musicDNA = new MusicDNA();
  var fileDropArea = document.getElementById('file-drop-area');
  var artist = document.getElementById('artist');
  var track = document.getElementById('track');
  var fileUploadForm = document.getElementById('file-chooser');
  var fileInput = document.getElementById('source-file');

  fileDropArea.addEventListener('drop', dropFile, false);
  fileDropArea.addEventListener('dragover', cancel, false);
  fileDropArea.addEventListener('dragenter', cancel, false);
  fileDropArea.addEventListener('dragexit', cancel, false);
  fileUploadForm.addEventListener('submit', onSubmit, false);

  function onSubmit(evt) {
    evt.preventDefault();
    evt.stopImmediatePropagation();

    if (fileInput.files.length)
      go(fileInput.files[0]);
  }

  function cancel(evt) {
    evt.preventDefault();
  }

  function dropFile(evt) {

    evt.stopPropagation();
    evt.preventDefault();

    var files = evt.dataTransfer.files;

    if (files.length) {
      go(files[0]);
    }
  }

  function go(file) {
    musicDNA.parse(file);
    fileDropArea.classList.add('dropped');

    ID3.loadTags("filename.mp3", function() {
      var tags = ID3.getAllTags("filename.mp3");
      if (tags.artist)
        artist.textContent = tags.artist;
      if (tags.title)
        track.textContent = tags.title;

      musicDNA.setName(tags.artist + ' - ' + tags.title);
    }, {
      dataReader: FileAPIReader(file)
    });
  }

})();
