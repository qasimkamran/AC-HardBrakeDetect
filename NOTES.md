## Notes

I wrote this out before starting any development as a practice I would like to continue for other projects, especially when AI usage may muddle the waters between understanding and implementation.

### Purpose

From this CSP app, I want a prompt to be displayed to the user when they have made a 'hard brake'.

Since the notes here are meant to take an informal structure. I will discuss in paragraph form, all the terms that are relevant to the discussion. When I state 'hard brake', it means  a brake initiated by the player that would cause a jerk and be detected as a fault in UK driving assessments, these assessments are rigorously examined by a committee of experts. I am no domain expert, and as such, the standards set out by the domain experts will be employed. The formal definition of which is condensed to the following "A hard brake is braking that produces abrupt deceleration due to non-progressive pedal input, resulting in noticeable vehicle pitch or occupant movement". I am aware that a when marking for a hard brake, circumstance mattera but that is not the purpose of this app. I want only the user to understand from their braking what maybe the simulation engine could not convey through just FFB and visual effects.
### Features

The following features are the core concept of the app, such that an MVP deliverable must have these features built-in to meet requirements.

- A UI element that conveys information to the player from our backend logic.

- Information printed as part of a UI element that indicates a YES / NO or equivalent to the player when hard brake is detected.
### Technical Constraints

The following constraints will be technical and are meant to guide the adequate function with more strictness on performant function rather than correctness (which is a given).

- Application must be performant in that it must indicate to the player when a hard brake is detected as quick as possible.

- Logging functionality must exist and be toggleable such that the logger will enable debugging and aid to reproduce simulation behaviors in an offline environment.

- As simple as can be programatically and algorithimically but no simpler. MVP is the goal here.

- It must be easy to perceive visually.

### Feature Implementation

Here, I have listed both the core features and how they are meant to be implemented in simple natural language terms that may relate to Lua concepts simply.

==A UI element that conveys information to the player from our backend logic.==

The CSP application will contain the main file `app.lua`, this file will include the function to render the prompt.

A `ui.lua` file will contain the elements and their creation powered by the returned paramters from our `detector.lua`.

All backend logic and algorithims will be defined and laid out in `detector.lua`.

==Information printed as part of a UI element that indicates a YES / NO or equivalent to the player when hard brake is detected.==

For now, we will simply display a rectangular emboldended unfilled red box to the user containing the text 'Hard Brake' in block capitals, red and emboldened with a transparent background as to not obstruct the cockpit view.

*Ideally the prompt should be moveable and be displayed by default on the top left corner as the test setup uses right-hand drive vehicles.*

This will be defined and implemented in `ui.lua` where the function wil take no arguments since it is not meant to make logic decisions.
### Constraint Implementation

Same as [Feature Implementation] section but for [Technical Constraints].

==Application must be performant in that it must indicate to the player when a hard brake is detected as quick as possible.==

The algorithm must use whatever is the least in complexity and avoid overfilling with edge cases. Be just as accurate to detect 90% of hard braking conditions.

==Logging functionality must exist and be toggleable such that the logger will enable debugging and aid to reproduce simulation behaviors in an offline environment.==

When enabled with debugging information, the CSP application should write telemetry data to a CSV file. The app should include a CSV parser and `detector.lua` should be able to use data from the CSV to analyse hard brakes just as it would with telemetry data directly from the game.

The logger should also write instance where the prompt was displayed in the events logfile. Which may not require any parser.

*Rest didn't seem to require any explanations.*
### Algorithm

In this section, we will iteratively go over all the logic that is required to parse in telemetry data from the simulation and indicate hard brakes.

For this algorithm we must define our inputs and outputs to the function and build around those constraints.
#### Input

An array of `Sample` objects that will be defined as a `Window` of these samples.
A sample will contain the following members: time (event time), current apeed and the current acceleration.
#### Output

A boolean value representing a hard brake detected or not detected.
#### Process

Samples will be gathered when the brake pedal is engaged until it is let go. A minimum number of samples based on duration will be checked against, if below a reasonable value then do not run the detection checks and skip this window.

Compute some meaningful values based on the samples gathered:
- Change in speed.
- Change in time.
- Peak decceleration reached 

If change in speed is negligible then the braking was not very meaningful over all and can be ruled out.

If peak decceleration was below a certain threshold, then it can be thought of as a hard brake.

If none of the above are caught for failure, then return true for hard brake detected.
