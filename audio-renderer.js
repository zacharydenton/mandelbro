/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

function AudioRenderer() {
	"use strict";

	var LOG_MAX = Math.log(128);
	var TAU = Math.PI * 2;
	var MAX_DOT_SIZE = 0.5;
	var BASE = Math.log(4) / LOG_MAX;
	var DELTA = 0.01;
	var OFFSET_DELTA = 0.01;
	var SHADERS = [
		"tripendulum",
		"julia",
		"boxes",
		"mandelbrot",
		"pendulum",
		"sinewaves",
		"dyson-sphere",
		"lightbeam",
		"monjori",
		"pulsating_wave",
		"stringy",
		"tunnel",
		"colordots"
	];
	var shaderIndex = -1;

	var scene = new THREE.Scene();
	var camera = new THREE.OrthographicCamera(-window.innerWidth / 2,
			window.innerWidth / 2, window.innerHeight / 2, -window.innerHeight / 2,
			-1000, 1000);
	camera.position.z = 100;
	camera.lookAt(scene.position);

	var material = new THREE.ShaderMaterial({
		uniforms: { 
			time: { type: "f", value: 0.0 },
			resolution: { type: "v2", value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
			speed: { type: "f", value: 1.0 },
			offset: { type: "v3", value: new THREE.Vector3(0, 0, 0) },
			volume: { type: "f", value: 0.0 },
			beat: { type: "f", value: 0.0 },
			bass: { type: "f", value: 0.0 },
			lowerMid: { type: "f", value: 0.0 },
			upperMid: { type: "f", value: 0.0 },
			highEnd: { type: "f", value: 0.0 }
		},
		vertexShader: document.getElementById( 'vertexShader' ).textContent,
		fragmentShader: document.getElementById( 'fragmentShader' ).textContent
	});
	var uniforms = material.uniforms;
	var plane = new THREE.PlaneGeometry(window.innerWidth, window.innerHeight);
	var quad = new THREE.Mesh(plane, material);
	quad.position.z = -100;
	scene.add(quad);

	var volumeSmooth = smooth();
	var beatSmooth = smooth();
	var bassSmooth = smooth();
	var lowerSmooth = smooth();
	var upperSmooth = smooth();
	var highSmooth = smooth();

	var mouseDx = 0.0;
	var mouseDy = 0.0;

	var renderer = new THREE.WebGLRenderer();
	document.getElementById('render-area').appendChild(renderer.domElement);

	function onResize() {
		renderer.setSize(window.innerWidth, window.innerHeight);
		uniforms.resolution.value = new THREE.Vector2(window.innerWidth, window.innerHeight);
	}

	function onMouseMove(e) {
		mouseDx = e.clientX / window.innerWidth - 0.5;
		mouseDy = 0.5 - e.clientY / window.innerHeight;
	}

	function onScroll(e) {
		uniforms.offset.value.z += OFFSET_DELTA * e.wheelDelta;
	}

	function onKeyPress(e) {
		if (e.keyCode === 32) {
			// spacebar pressed
			loadNextShader();
		}
	}

	function clamp(val, min, max) {
		return Math.min(max, Math.max(val, min));
	}

	function average(vals) {
		var sum = 0;
		for (var i = 0, l = vals.length; i < l; i++)
			sum += vals[i];
		return sum / vals.length;
	}

	function smooth(maxStep, minStep) {
		if (maxStep === undefined) {
			maxStep = 0.1;
		}
		if (minStep === undefined) {
			minStep = 0.005;
		}
		var prevValue = 0;
		return function(value) {
			if (Math.abs(value - prevValue) < minStep) {
				return prevValue;
			} else if (Math.abs(value - prevValue) < maxStep) {
				prevValue = value;
				return value;
			}
			var sign = (value > prevValue) ? 1 : -1;
			prevValue += sign * maxStep;
			return prevValue;
		}
	}

	function loadShader(name) {
		var xhr = new XMLHttpRequest();
		xhr.open('GET', "shaders/" + name + ".glsl?" + Date.now(), true);
		xhr.onload = function() {
			material.fragmentShader = xhr.responseText;
			material.needsUpdate = true;
		};
		xhr.send();
	}

	function loadRandomShader() {
		shaderIndex = Math.floor(Math.random() * SHADERS.length)
		var nextShader = SHADERS[shaderIndex];
		loadShader(nextShader);
	}

	function loadNextShader() {
		shaderIndex += 1;
		shaderIndex %= SHADERS.length;
		var nextShader = SHADERS[shaderIndex];
		loadShader(nextShader);
	}

	this.clear = function() {
		renderer.clear();
	};

	this.render = function(audioData, audioTime) {
		uniforms.time.value = audioTime;
		var mouseOffset = new THREE.Vector3(mouseDx, mouseDy, 0).multiplyScalar(OFFSET_DELTA);
		uniforms.offset.value.add(mouseOffset);

		var bassEnd = audioData.length / 32;
		var lowerEnd = bassEnd + audioData.length / 16;
		var upperEnd = lowerEnd + audioData.length / 8;
		var highEnd = upperEnd + audioData.length / 4;

		var bass = uniforms.bass.value = bassSmooth(average(audioData.subarray(0, bassEnd)) / 255);
		var lower = uniforms.lowerMid.value = lowerSmooth(average(audioData.subarray(bassEnd, lowerEnd)) / 255);
		var upper = uniforms.upperMid.value = upperSmooth(average(audioData.subarray(lowerEnd, upperEnd)) / 255);
		var high = uniforms.highEnd.value = highSmooth(average(audioData.subarray(upperEnd, highEnd)) / 255);

		uniforms.beat.value = beatSmooth(bass);
		uniforms.volume.value = volumeSmooth(average([bass, lower, upper, high]));

		renderer.clear();

		// Render full screen quad with shader
		renderer.render( scene, camera );
	};

	window.addEventListener('resize', onResize, false);
	window.addEventListener('mousemove', onMouseMove, false);
	window.addEventListener('mousewheel', onScroll, false);
	window.addEventListener('keypress', onKeyPress, false);
	window.addEventListener('load', function() {
		loadNextShader();
		onResize();
	}, false);
}
