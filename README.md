# 🎯 Laser Whac-A-Mole: Precision Shooting Challenge  

This project is the **Final Project of CS2104 Hardware Design Lab**.  
We designed and implemented an interactive shooting game on FPGA that integrates a **laser gun, IR receivers, VGA display, and audio system**. Inspired by carnival balloon-shooting games, the player uses a laser gun to hit targets within a limited number of rounds.  

## 📌 System Architecture  

The system is divided into two main components:  

- **Gun (Laser Shooter)**  
  - Laser Diode  
  - Bipolar Junction Transistor (BJT) for switching  
  - External 15V power supply  
  - LED & 7-segment display for bullet/energy status  
  - Buzzer for shooting indication  

- **Target (Receiver Board)**  
  - IR Receivers  
  - VGA display output  
  - Pmod Audio for sound effects  
  - External LEDs for target indication  

## 🎮 Game Flow  

1. Press the start button to begin the game.  
2. A **3-second countdown** is shown.  
3. When the LED lights up, the player starts shooting targets across **6 rounds**.  
4. The player can miss up to 3 times; exceeding this ends the game.  
5. VGA displays game scenes and countdowns, while audio provides stage-specific effects.  
6. A **Win/Loss screen** is displayed at the end based on performance.  

## 🛠️ Technical Details  

- **Gun**  
  - FPGA output drives a **BJT switch**, enabling a 15V power supply to fire the laser.  
  - A counter tracks remaining bullets (0–100), displayed on the 7-segment display.  
  - LEDs and buzzer provide synchronized shooting feedback.  

- **Target**  
  - Implemented using an **FSM (Finite State Machine)** with INIT → COUNTDOWN → GAME → FINISH states.  
  - VGA shows start screen, countdown, in-game timer, and final results.  
  - Pmod Audio generates different sound effects for each stage.  
  - IR Receiver + LED combinations light up in sequence as shooting targets.  

## ⚡ Project Outcome & Challenges  

- **Completion: 95/100**  
- **Difficulty: 95/100**  

**Key Challenges:**  
- FPGA’s limited current could not power the laser directly → solved using **BJT + external 15V power supply**.  
- Implementing VGA countdown required a **5x6 grid mapping approach** to display numbers dynamically.  

## 👥 Team Contribution  

- **Hsiang-Chen Chiu**: Laser diode + BJT, VGA, LED, report writing  
- **Po-Hsun Tseng**: Target (IR receivers + LEDs), switch, LED, audio, VGA, assembly  

## 💡 Reflection  

This project provided a complete experience from **hardware circuit design to Verilog implementation and gameplay mechanics**. We overcame challenges such as external power integration and VGA control, ultimately delivering a fun and interactive shooting game. Through this work, we deepened our understanding of FPGA-based digital design and gained valuable hands-on experience.  
