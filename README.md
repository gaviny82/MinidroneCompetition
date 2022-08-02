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


# Documentation

[Getting Started](docs/Getting%20Started.md)

[Minidrone Hardware and Controller](docs/Minidrone%20Hardware%20and%20Controller.md)

[Simulink Model Interface](docs/Simulink%20Model%20Interface%20Definition.md)


# Folder structure

- The whole Simulink project is in the `parrotMinidroneCompetition` folder and this contains the project files to be submitted. 

  - The flight control system is in the sub-folder `controller/flightControlSystem.slx`. This file includes both the image processing and control systems.
  - The `linearAirframe` module in `Multicopter Model` is in `parrotMinidroneCompetition/linearAirframe/linearAirframe.slx`.
  - The `nonlinearAirframe` module in `Multicopter Model` is in `parrotMinidroneCompetition/nonlinearAirframe/nonlinearAirframe.slx`.

  - The other modules of the model are in `parrotMinidroneCompetition/mainModels/parrotMinidroneCompetition.slx`.

- Documentation of this project is in the `docs` folder.


## Submission requirement

As per Section B.2 and B.4 in [Competition guidelines](https://uk.mathworks.com/content/dam/mathworks/mathworks-dot-com/academia/student-competitions/minidrone-competition/mathworks-minidrone-competition-guidelines.pdf),

- Do **NOT** add any Simulink models or MATLAB files to the subfolders. If you have written any additional MATLAB files or Simulink models, you can add them to the main `parrotMinidroneCompetition` model folder. 
- The model must be **code generation capable**. This can be tested by generating C code when the Flight Control System is opened as the top model.

As described in [Model description](https://uk.mathworks.com/videos/mathworks-minidrone-competition-model-description-1551445160030.html) 3:02, only the following modules are expected to be edited.
- `parrotMinidroneCompetition/Flight Control System (flightControlSystem)/Control System/Path Planning`
- `parrotMinidroneCompetition/Flight Control System (flightControlSystem)/Image Processing System`
