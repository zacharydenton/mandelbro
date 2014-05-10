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
			offset: { type: "v3", value: new THREE.Vector2(0, 0, 0) },
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

	var renderer = new THREE.WebGLRenderer();
	document.getElementById('render-area').appendChild(renderer.domElement);

	function onResize() {
		renderer.setSize(window.innerWidth, window.innerHeight);
		uniforms.resolution.value = new THREE.Vector2(window.innerWidth, window.innerHeight);
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

	this.clear = function() {
		renderer.clear();
	};

	this.render = function(audioData, normalizedPosition) {
		uniforms.time.value = normalizedPosition;

		var bassEnd = audioData.length / 16;
		var lowerEnd = bassEnd + audioData.length / 8;
		var upperEnd = lowerEnd + audioData.length / 4;

		var bass = uniforms.bass.value = average(audioData.subarray(0, bassEnd));
		var lower = uniforms.lowerMid.value = average(audioData.subarray(bassEnd, lowerEnd));
		var upper = uniforms.upperMid.value = average(audioData.subarray(lowerEnd, upperEnd));
		var high = uniforms.highEnd.value = average(audioData.subarray(upperEnd));

		uniforms.beat.value = bass;
		uniforms.volume.value = average([bass, lower, upper, high]);

		renderer.clear();

		// Render full screen quad with shader
		renderer.render( scene, camera );
	};

	window.addEventListener('resize', onResize, false);
	window.addEventListener('load', function() {
		onResize();
	}, false);
}
