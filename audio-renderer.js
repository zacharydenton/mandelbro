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

	var material = new THREE.ShaderMaterial({
		uniforms: { 
			time: { type: "f", value: 0.0 },
			resolution: { type: "v2", value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
			mouse: { type: "v2", value: new THREE.Vector2(0.5, 0.5) }
		},
		vertexShader: document.getElementById( 'vertexShader' ).textContent,
		fragmentShader: document.getElementById( 'fragmentShader' ).textContent

	});
	var plane = new THREE.PlaneGeometry(window.innerWidth, window.innerHeight);
	var quad = new THREE.Mesh(plane, material);
	quad.position.z = -100;
	scene.add(quad);

	var renderer = new THREE.WebGLRenderer();
	document.getElementById('render-area').appendChild(renderer.domElement);

	function onResize() {
		renderer.setSize(window.innerWidth, window.innerHeight);
	}

	function clamp(val, min, max) {
		return Math.min(max, Math.max(val, min));
	}

	this.clear = function() {
		renderer.clear();
	};

	this.render = function(audioData, normalizedPosition) {
		var time = Date.now() * 0.0015;

		camera.lookAt(scene.position);

		if ( material.uniforms.time.value > 1 || material.uniforms.time.value < 0 ) {
			DELTA *= -1;
		}

		material.uniforms.time.value += DELTA;

		renderer.clear();

		// Render full screen quad with shader
		renderer.render( scene, camera );
	};

	window.addEventListener('resize', onResize, false);
	window.addEventListener('load', function() {
		onResize();
	}, false);
}
