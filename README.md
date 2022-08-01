# Minidrone Competition 2022
This example is the reference model to be used by participants of the MathWorks Minidrone Competition.

## Competition Timeline
| Task                  | Deadline    |
| --------------------- | ----------- |
| Application           | 1 Aug 2022  |
| Simulation Submission | 16 Aug 2022 |
| Finalists Declaration | 19 Sep 2022 |
| Video Submission      | 10 Oct 2022 |
| Final Round           | 28 Oct 2022 |



# Resources

[Competition guidelines](https://uk.mathworks.com/content/dam/mathworks/mathworks-dot-com/academia/student-competitions/minidrone-competition/mathworks-minidrone-competition-guidelines.pdf)

[MathWorks Minidome Competition video series](https://uk.mathworks.com/videos/series/mathworks-minidrone-competition.html)

[Parrot Minidrones Support from Simulink](https://uk.mathworks.com/hardware-support/parrot-minidrones.html)

[Documentation - Quadcopter Project](https://uk.mathworks.com/help/aeroblks/quadcopter-project.html)

[Webinar – Programming Drones with Simulink (24:53)](https://uk.mathworks.com/videos/programming-drones-with-simulink-1525123168579.html) 

[Webinar – Drone Simulation and Control](https://uk.mathworks.com/videos/series/drone-simulation-and-control.html)

[Online courses](https://uk.mathworks.com/academia/targeted/online-learning.html)

[Version control](https://uk.mathworks.com/help/simulink/ug/set-up-git-source-control.html)



# Development environment

The latest release of MATLAB was R2022a (released on 9 Mar 2022) when the competition was launched (as per Section B.2 in [Competition guidelines](https://uk.mathworks.com/content/dam/mathworks/mathworks-dot-com/academia/student-competitions/minidrone-competition/mathworks-minidrone-competition-guidelines.pdf)).

Add-ons required:
- Aerospace Blockset

- Aerospace Toolbox

- Computer Vision Toolbox

- Control System Toolbox

- Image Processing Toolbox

- Signal Processing Toolbox

- Simulink

- Simulink 3D Animation

- Simulink Control Design

- Simulink Support Package for Parrot Minidrones

- Stateflow

  <br>

- Embedded Coder

- MATLAB Coder

- Simulink Coder

  <br>

Additional software:
- Git (see [Version control](https://uk.mathworks.com/help/simulink/ug/set-up-git-source-control.html))
- A [supported compiler](https://uk.mathworks.com/support/requirements/supported-compilers.html) for code generation (Microsoft Visual C++ 2019 is recommended for Windows or Xcode 13.x for macOS)

<br>

Run this command in MATLAB to generate a new project:

```matlab
>> parrotMinidroneCompetitionStart
```



# Folder structure

- The flight control system is in `controller/flightControlSystem.slx`. This file includes both the image processing and control systems.
- The `linearAirframe` module in `Multicopter Model` is in `linearAirframe/linearAirframe.slx`.
- The `nonlinearAirframe` module in `Multicopter Model` is in `nonlinearAirframe/nonlinearAirframe.slx`.

- The other parts of the model are in `mainModels/parrotMinidroneCompetition.slx`.

- Documentation should be stored in the `docs` folder.



## Submission requirement

As per Section B.2 and B.4 in [Competition guidelines](https://uk.mathworks.com/content/dam/mathworks/mathworks-dot-com/academia/student-competitions/minidrone-competition/mathworks-minidrone-competition-guidelines.pdf),

- Do **NOT** add any Simulink models or MATLAB files to the subfolders. If you have written any additional MATLAB files or Simulink models, you can add them to the main `parrotMinidroneCompetition` model folder. 
- The model must be **code generation capable**. This can be tested by generating C code when the Flight Control System is opened as the top model.

As described in [Model description](https://uk.mathworks.com/videos/mathworks-minidrone-competition-model-description-1551445160030.html) 3:02, only the following modules are expected to be edited.
- `parrotMinidroneCompetition/Flight Control System (flightControlSystem)/Control System/Path Planning`
- `parrotMinidroneCompetition/Flight Control System (flightControlSystem)/Image Processing System`
