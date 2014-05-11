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

    var mandelbro = new Mandelbro();
    var fileDropArea = document.getElementById('file-drop-area');
    var artistEl = document.getElementById('artist');
    var trackEl = document.getElementById('track');
    var soundcloudSearch = document.getElementById('sc-search');

    fileDropArea.addEventListener('drop', dropFile, false);
    fileDropArea.addEventListener('dragover', cancel, false);
    fileDropArea.addEventListener('dragenter', cancel, false);
    fileDropArea.addEventListener('dragexit', cancel, false);
    soundcloudSearch.addEventListener('keypress', onKeyPress, false);

    function getJSON(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', url, true);
        xhr.onload = function() {
            callback(JSON.parse(xhr.responseText));
        };
        xhr.send();
    }

    function getBinary(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', url, true);
        xhr.responsetype = "arraybuffer";
        xhr.onload = function() {
            callback(xhr.response);
        };
        xhr.send();
    }

    function onKeyPress(evt) {
        if (evt.keyCode === 13) {
            var url = soundcloudSearch.value;
            if (!url.indexOf("http") !== 0) {
                url = "http://" + url;
            }
            getJSON("http://api.soundcloud.com/resolve.json?url=" + encodeURIComponent(url) + "&client_id=6561f9221ad293bd6e88e8d1a87bd20f", function(result) {
                goSoundcloud(result);
            });
        }
    }

    function dropFile(evt) {

        evt.stopPropagation();
        evt.preventDefault();

        var files = evt.dataTransfer.files;

        if (files.length) {
            go(files[0]);
        }
    }

    function cancel(evt) {
        evt.preventDefault();
    }

    function go(file) {
        mandelbro.parse(file);
        fileDropArea.classList.add('dropped');

        ID3.loadTags("filename.mp3", function() {
            var tags = ID3.getAllTags("filename.mp3");
            if (tags.artist)
                artistEl.textContent = tags.artist;
            if (tags.title)
                trackEl.textContent = tags.title;

            mandelbro.setName(tags.artist + ' - ' + tags.title);
        }, {
            dataReader: FileAPIReader(file)
        });
    }

    function goSoundcloud(track) {
        artistEl.textContent = track.user.username;
        trackEl.textContent = track.title;
        mandelbro.setName(track.user.username + ' - ' + track.title);
        mandelbro.parseStream(track.stream_url + "?client_id=6561f9221ad293bd6e88e8d1a87bd20f", track.duration / 1000);
        fileDropArea.classList.add('dropped');
    }

})();
