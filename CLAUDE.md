# CLAUDE.md — Context File for AI-Assisted Engineering Work

> This file provides persistent context for Claude when collaborating on academic and professional projects in Automation and Control Engineering. It defines who I am, how I work, and the standards I expect in every interaction.

---

## 1. User Profile

**Role:** Automation and Control Engineer  
**Domain:** Academic research and personal projects at the intersection of control theory, industrial automation, and software engineering.

**Background:**
- Formal training in systems and automation engineering, with solid foundations in mathematical modeling, dynamic systems analysis, and feedback control theory.
- Experience spanning both theoretical frameworks (state-space representation, transfer functions, stability analysis) and applied industrial contexts (PLCs, SCADA systems, sensor integration, process control).
- Active engagement with real-world case studies, converting engineering problems into structured analytical workflows.

**Current Focus Areas:**
- Control system design and simulation (linear/nonlinear, continuous/discrete-time)
- Mathematical modeling of physical systems (mechanical, electrical, thermal, hybrid)
- Industrial automation architectures and protocols
- Data-driven engineering: signal processing, system identification, and performance metrics
- Software development for engineering applications (tooling, simulation environments, data pipelines)

---

## 2. Core Tech Stack

### Primary Languages

| Language | Use Case |
|---|---|
| **Python** | Data analysis, scripting, control simulations, automation tooling |
| **MATLAB / Simulink** | Control design, system simulation, model-based development |
| **C / C++** | Embedded systems, real-time control, performance-critical modules |
| **Structured Text (IEC 61131-3)** | PLC programming and industrial logic |
| **HTML / CSS / JavaScript** | Engineering dashboards, documentation, lightweight web interfaces |

### Key Libraries & Frameworks

- **Python:** `numpy`, `scipy`, `sympy`, `control`, `matplotlib`, `pandas`, `scikit-learn`, `pytest`
- **MATLAB:** Control System Toolbox, Simulink, Signal Processing Toolbox
- **Data & Visualization:** `plotly`, `seaborn`, `jupyter`

### Tools & Environments

- **Version Control:** Git (GitHub / GitLab)
- **IDEs:** VS Code, MATLAB IDE, Jupyter Lab
- **Documentation:** Markdown, LaTeX (for formal reports and theses)
- **Industrial Protocols:** Modbus, OPC-UA, PROFINET (reference-level familiarity)
- **OS:** Linux (preferred for development), Windows (MATLAB/Simulink environments)

---

## 3. Guiding Principles

### Code Standards

- **Correctness first:** Code must be mathematically and logically sound. Engineering simulations with incorrect numerical behavior are worse than no code at all.
- **Readability:** Use meaningful variable names that reflect physical quantities (e.g., `omega_n` for natural frequency, `zeta` for damping ratio). Avoid single-letter variables except in established mathematical contexts (e.g., loop indices `i`, `j`; state vectors `x`, `u`, `y`).
- **Rigorous comments:** Every non-trivial function must include a docstring specifying inputs, outputs, units, and assumptions. Inline comments should explain *why*, not *what*.
- **Modularity:** Prefer small, testable functions over monolithic scripts. Separate model definitions, solvers, and visualization layers.
- **Units discipline:** Always specify physical units in variable names, comments, or docstrings. Mixed-unit bugs are silent and catastrophic in engineering contexts.
- **Numerical robustness:** Be explicit about time steps, solver tolerances, and stability margins. Flag potential numerical issues (e.g., stiff ODEs, ill-conditioned matrices).

```python
# Example of expected comment style
def pid_controller(e: float, e_integral: float, e_prev: float,
                   Kp: float, Ki: float, Kd: float, dt: float) -> float:
    """
    Discrete-time PID controller (forward Euler integration).

    Args:
        e           : Current error signal [engineering units]
        e_integral  : Accumulated integral of error [units * s]
        e_prev      : Error at previous timestep [units]
        Kp, Ki, Kd  : PID gains [units-dependent]
        dt          : Sampling period [s]

    Returns:
        u : Control action [actuator units]
    """
    u = Kp * e + Ki * e_integral + Kd * (e - e_prev) / dt
    return u
```

### Case Study Analysis Standards

- Structure analysis as: **Problem Definition → System Modeling → Analysis → Design/Solution → Validation → Conclusions**.
- Always identify and state assumptions explicitly before proceeding with any model.
- Quantify performance metrics where possible (settling time, overshoot, RMSE, stability margins, etc.).
- Distinguish clearly between simulation results and real-world validated data.
- Reference established control/automation literature or standards (IEEE, ISA, IEC) when applicable.

---

## 4. Communication Style

**Tone:** Technical, precise, and direct. No filler phrases, no excessive preamble.

**Response Format:**
- Lead with the answer or solution, then provide supporting explanation.
- Use equations when they add clarity; prefer LaTeX notation in Markdown (e.g., `$\dot{x} = Ax + Bu$`).
- Structure complex responses with clear headers. Keep prose tight.
- When presenting code, always include the language tag in fenced blocks and add a brief description of what the block does.
- If a question is ambiguous, flag the ambiguity and state the assumption made before proceeding — do not silently pick an interpretation.

**What to avoid:**
- Generic advice not grounded in engineering context.
- Overlong explanations of concepts I am assumed to know (e.g., don't explain what a Bode plot is unless asked).
- Hallucinated numerical results or fabricated references. If uncertain, say so explicitly.
- Aesthetic refactoring of working code unless explicitly requested.

**When to ask for clarification:**
- When system parameters, operating conditions, or design constraints are missing and would materially change the solution.
- When a task could be interpreted at different levels of abstraction (e.g., conceptual design vs. full implementation).

---

## 5. Workflow

### Theory → Implementation Pipeline

```
Problem Statement
      │
      ▼
Mathematical Modeling
(ODEs, transfer functions, state-space, block diagrams)
      │
      ▼
Analytical / Simulation Analysis
(MATLAB/Simulink or Python control libraries)
      │
      ▼
Controller / Algorithm Design
(with documented design criteria and trade-offs)
      │
      ▼
Verification & Validation
(unit tests, numerical validation, comparison with analytical solutions)
      │
      ▼
Implementation & Documentation
(clean code, reproducible results, commented outputs)
```

### Session Conventions

- **Start of task:** If I provide a problem statement or case study, identify the system type and suggest a modeling approach before writing code.
- **Iterative refinement:** Prefer incremental, reviewable steps over large monolithic outputs. Deliver working partial solutions I can test before building further.
- **File and project conventions:** Use snake_case for Python files and variables; camelCase for JavaScript; UPPER_SNAKE_CASE for constants and physical parameters that are fixed across a simulation.
- **Reproducibility:** Simulations must produce deterministic outputs. Seed random number generators explicitly. Document solver configurations.
- **MATLAB ↔ Python parity:** When implementing the same model in both environments, align variable naming and structural conventions so cross-validation is straightforward.

### Academic Context Awareness

- Distinguish between *pedagogical examples* (where simplicity and clarity of exposition matter) and *research-grade implementations* (where rigor, scalability, and validation matter).
- When working on academic deliverables (reports, theses, presentations), maintain consistent notation aligned with the document's mathematical framework.
- Always flag if a shortcut taken for speed would be inappropriate in a formal academic or industrial submission.

---

*Last updated: 2026 — Automation and Control Engineering context.*
