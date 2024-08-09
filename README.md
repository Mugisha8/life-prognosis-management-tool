---------------- Life Prognosis & Management Tool (Life Expectancy calculation) -------------------------


Overview

Life Prognosis TOOL is a Java and Bash-based application that facilitates user registration, login, and life expectancy calculations based on various factors including HIV status and ART drug usage.

Prerequisites

Before running the application, ensure you have the following installed on your system:

Java Development Kit (JDK) 8 or higher
Git Bash (for running the Bash scripts on Windows)
OpenSSL (for password hashing)
A Unix-like terminal (for non-Windows users)

How to Run the Application

### Step 1: Clone the Repository
If you haven't already, clone the repository to your local machine:

Commands:
git clone https://github.com/your-repository/kalisimbi_app.git
cd kalisimbi_app

### Step 2: Compile the Java Application
Navigate to the src directory and compile the Java program:

Commands:
cd src
javac Kalisimbi_App.java

Step 3: Run the Application
After compilation, run the Java application:

Commands:
java Kalisimbi_App

### Step 4: Use the Application
Once the application starts, you will be presented with the following menu options:

Complete Registration: Completes the registration process for users initiated by an admin.
Login: Logs in a user. Admins can initiate new user registration and download user data, while patients can view and update their profiles and calculate life expectancy.
Exit: Closes the application.


Example Commands

Login Example
Select "LOGIN" from the menu.
Enter your email and password.

Complete Registration Example
Select "Complete Registration" from the menu.
Follow the on-screen prompts to enter user details.

Known Issues
Ensure you have the necessary permissions to execute Bash scripts on your system.
Compatibility issues may arise if not running on a Unix-like environment or using Git Bash on Windows.


Prepared by Kalisimbi-4 Team

