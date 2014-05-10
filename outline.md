Mandelbro
---------

-   interactive music fractalizer
-   full screen quad shader w/ three.js
-   modify shaders to use 16 different uniforms
    -   these uniforms are tied to fft and bcr2000 for manual control

Plan
----

-   modify [base code][] to use full-screen quad shader
    -   see also:
        <http://www.airtightinteractive.com/demos/js/pareidolia/>,
        <http://www.airtightinteractive.com/2013/10/making-audio-reactive-visuals/>

-   create uniforms tied to fft - 16 different vars
-   modify shaders to use these uniforms
-   at this point, basically finished. add BCR2000 midi support for
    manual control.
-   implement beat detection algorithm and assign this to first uniform.
    assume that first parameter is most important in shaders.

Basic functionality
-------------------

-   load webpage.
-   load song via drag/drop.
-   the visualizer shuffles the list of fractals, and loads the first
    one.
-   smoothly fade between fractals when there is a transition in the
    song (or when spacebar is pressed).
    -   for a smooth transition: draw both, fade one in, fade the other
        out.

Parameters
----------

1.  Beat detection
2.  Overall sound level
3.  Next 4 will be log scaled spectrum slices [0,1]
    -   0-150 (bass)
    -   150-600 (lower midrange)
    -   600-2000 (upper midrange)
    -   2000-20000 (high end)

4.  multiple parameters for midi controls
    -   possible global controls for zoom, time fast-forward/rewind,
        etc.

5.  possibly use waveform as a source of 'randomness' (texture1D)
    -   anything previously random will now be in tune with the music

Shader List
-----------

-   <http://glsl.heroku.com/e#14767.0>
-   <http://glsl.heroku.com/e#14940.12>
-   <http://glsl.heroku.com/e#1683.0>
-   <http://glsl.heroku.com/e#16332.0>
-   <http://glsl.heroku.com/e#13314.10>
-   <http://glsl.heroku.com/e#16079.0>
-   <http://glsl.heroku.com/e#16063.0>
-   <http://glsl.heroku.com/e#15920.0>
-   <http://glsl.heroku.com/e#15923.0>
-   <http://glsl.heroku.com/e#15771.0>
-   <http://glsl.heroku.com/e#15363.1>
-   <http://glsl.heroku.com/e#14767.0>
-   <http://glsl.heroku.com/e#15521.0>
-   <http://glsl.heroku.com/e#11208.1>

  [base code]: https://github.com/paullewis/music-dna

Shader Variables
----------------

float speed
vec3 offset (offset.x, offset.y, offset.z)
float beat
float zoom 





















