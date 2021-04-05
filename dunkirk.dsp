/*
    Copyright (C) 2021 by Grégoire Locqueville <gregoireloc@gmail.com>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
    "Shepard" pitch shifting: several copies of the input are pitch-shifted
    with an offset of 12 semitones between consecutive voices,
    and gains are applied, so that transposing 12 semitones is the same as
    transposing 0 semitones
*/

import("stdfaust.lib");


transposition = vslider("Transposition[style:knob]", 0, -6, 6, 0.01); // in semitones
halfNbVoices = 1; // we need an even number of voices for things to be balanced

// Pitch shifting algorithm parameters
wsize = hslider("Window (samples)", 1000, 50, 10000, 1);
xfade = hslider("Crossfade (samples)", 10, 1, 10000, 1);

//--------------------------------------------------------------------------

// Whatever the transposition value was, we reposition it so it's between 0 and 12
cyclic_transp = ma.modulo(transposition, 12);

// Pitch offset of the ith voice
transp(i) = (i-halfNbVoices) * 12 + cyclic_transp;
// Gain of the ith voice
gain(i) = (1 - abs(transp(i))/(halfNbVoices*12)) / halfNbVoices;

voice(i) = ef.transpose(wsize, xfade, transp(i)) : (_*gain(i));


process = _ <: par(i, 2*halfNbVoices, voice(i)) :> _;

