************************************************************************************
                                  FlySiesta
                              version 0.931 (beta)

                   http://www.neural-circuits.org/flysiesta
 
Copyright (C) 2007-2011 Amanda Sorribes, Universidad Autonoma de Madrid, and
                        Consejo Superior de Investigaciones Cientificas (CSIC).

For info on future releases, comments, bug reports, improvements or feature
requests, join the FlySiesta Google Group: http://groups.google.com/group/flysiesta

or write to: amanda@neural-circuits.org
************************************************************************************

Contents
--------------------------
I. Brief Description
II. Installation & Usage
III. Requirements
IV. Bug Reports & Improvements
V. Acknowledgements
VI. License


I. Brief Description
-------------------------------------------------------------------------
FlySiesta is a MATLAB based program that analyzes activity and sleep
data of flies. The program has been tuned to read data files obtained
with the Drosophila Activity Monitoring (DAM) System, by TriKinetics.

Although the program extracts "general" activity parameters such as 
the activity and sleep profiles, the total time of activity/sleep, 
mean bout lengths and number of bouts - FlySiesta's main focus lies 
in analyzing the fine scale dynamics of the transitions between 
the behavioral states, by studying the 'burstiness' of the inter-
event-interval or event-length distributions.

For more information on how to interpret the burstiness parameters,
see
A Sorribes, BG Armendariz, D Lopez-Pigozzi, C Murga & GG de Polavieja, 
The Origin of Behavioral Bursts in Decision-Making Circuitry 
(Submitted), 
or the FlySiesta homepage for an updated reference.


II. Installation & Usage
-------------------------------------------------------------------------
1. Unzip the files. 
The files unzip into a folder named 'FlySiesta', which in turn has a 
subfolder named 'fsaux'. The FlySiesta folder can now be moved to any
desired location (but keep the internal structure of the files and
subfolders).

2. Open MATLAB, and browse to the FlySiesta folder.

3. Type "install_flysiesta" (without the quotes) in MATLAB.
This will add the FlySiesta folder and subfolders to Matlab's path, so
the program can be run from any location from now on.

4. Type "flysiesta" (lower-case, no quotes) to run the program.

For help on using the program, see the FlySiesta User Guide, at
http://www.neural-circuits.org/flysiesta/userguide


III. Requirements
-------------------------------------------------------------------------
Apart from Matlab, FlySiesta requires Matlab's Statistical Toolbox 
and Matlab's Curve Fitting Toolbox, to perform its analysis.


IV. Bug Reports & Improvements
-------------------------------------------------------------------------
FlySiesta version 0.93 (beta) has been written in Matlab 2007b on a 
Windows (XP and Vista) platform. It is my hope that it will also work
in newer (and maybe older) versions of Matlab, and on other platforms, 
but this has not been tested yet.

If you encounter any bugs or error messages while using the program, 
please post it on the FlySiesta Google Group:
http://groups.google.com/group/flysiesta

or write me at: amanda@neural-circuits.org

If possible, please include the error message (the red message in the
Matlab Command window), what you did when it occurred, which version of
FlySiesta and of Matlab you are using, and the operating system.

If you are proficient in Matlab programming and have made improvements
to the code, please contact me and/or send me the code, so that we can 
incorporate it into the next release. Help in developing FlySiesta
is gratefully received!


V. Acknowledgements
-------------------------------------------------------------------------
This program has been written by Amanda Sorribes, while in Gonzalo G. 
de Polavieja's Lab (Neural Processing Group) at the Universidad 
Autonoma de Madrid and (Systems Neuroscience Group) at the Cajal 
Institute, Consejo Superior de Investigaciones Cientificas, Spain.

If you publish or present results that are based, or have made use of 
any part of the program, acknowledge FlySiesta and cite:
A Sorribes, BG Armendariz, D Lopez-Pigozzi, C Murga & GG de Polavieja,
The Origin of Behavioral Bursts in Decision-Making Circuitry 
(Submitted).
Please see the FlySiesta homepage for an updated reference.

This program would not have been possible, without the support of
the following research funding agencies:
* Comunidad de Madrid
  - Programa Personal Investigador de Apoyo
  - Programa Biociencia
* The European Social Fund
* Universidad Autonoma de Madrid
* Ministerio de Ciencia e Inovacion
* Ministerio de Sanidad 
* The Cardiovascular Network RECAVA
* Eranet SysBio+

I also want to especially thank Beatriz G. Armendariz, for testing,
feedback and the endless patience during the development period, as 
well as Diego Lopez-Pigozzi. A special thanks to Enrique Turiegano 
and Alicia Gonzalo for testing the 'basic' version of the program
and for all the positive input and support.

Finally, I want to acknowledge the great icon set by Mark James, 
"Silk" (version 1.3), which you can get under Creative Commons 
Attribution 2.5 License, from http://www.famfamfam.com/lab/icons/silk
and tabpanel version 2.6, (c) by Elmar Tarajan (MCommander@gmx.de), 
which has been used with some modifications, in some of the 
FlySiesta subprograms.


VI. License
-------------------------------------------------------------------------
This program is free software: you can redistribute it and/or modify 
it under the terms of the GNU General Public License as published by 
the Free Software Foundation, either version 3 of the License, or 
any later version.

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
GNU General Public License for more details. 

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

