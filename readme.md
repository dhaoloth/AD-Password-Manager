# AD Password Manager

## Overview

This PowerShell script assists IT administrators with managing Active Directory (AD) user passwords. It provides functionalities for:

- **Admin Authentication**: Verifies administrator credentials and group membership.
- **Password Generation**: Creates secure, random passwords.
- **Email Notification**: Sends an email with new credentials.
- **Logging**: Records password changes in a log file.

## Features

- **Secure Authentication**: Validates admin access through group membership.
- **Customizable Passwords**: Option to auto-generate or manually input passwords.
- **Automated Email Alerts**: Sends notifications to specified users about password changes.
- **Detailed Logging**: Maintains a record of all password changes for auditing purposes.

## Getting Started

### Prerequisites

- **PowerShell**: Ensure you have PowerShell installed on your system.
- **Active Directory Module**: The script requires the Active Directory module, which is included in the Remote Server Administration Tools (RSAT).

### Configuration

1. **Download the Script**:
   - Clone or download the repository containing the PowerShell script.

2. **Update Configuration**:
   - Open the `script-comments.md` file for detailed instructions on configuring the script. This file provides guidance on how to replace placeholders with actual values specific to your environment.

3. **Run the Script**:
   - Open PowerShell as an administrator.
   - Execute the script by navigating to its directory and running: 
     ```powershell
     .\YourScriptName.ps1
     ```

### How to Use

1. **Authenticate**:
   - When prompted, enter your admin credentials and the DN of your admin group.

2. **Password Management**:
   - Input the login of the user whose password needs to be reset. Choose to generate a new password or enter one manually.

3. **Notification and Logging**:
   - Provide the email address for the notification. The script will send an email and log the change in the specified log file.

4. **Repeat or Exit**:
   - Indicate if another password change is needed or terminate the script.

## Additional Notes

- **Testing**: It’s advisable to test the script in a non-production environment before deploying it in a live setting.
- **Permissions**: Ensure that you have the necessary permissions to execute the script and write to the log path.

## Converting the Script to an Executable

To convert the PowerShell script into an executable (`.exe`), you can use the `Invoke-PS2EXE` tool. Follow these steps:

1. **Install PS2EXE Module**:
   - Open PowerShell and install the `PS2EXE` module via PowerShell Gallery:
     ```powershell
     Install-Module -Name ps2exe -Scope CurrentUser
     ```

2. **Convert the Script**:
   - Use the `Invoke-PS2EXE` command to convert the `.ps1` file to an `.exe` file:
     ```powershell
     Invoke-PS2EXE -InputFile .\YourScriptName.ps1 -OutputFile .\YourExecutableName.exe
     ```
   - **Parameters**:
     - `-InputFile`: Path to your PowerShell script.
     - `-OutputFile`: Path where you want the executable to be saved.

3. **Distribute the Executable**:
   - You can now distribute the `.exe` file. It will run independently of PowerShell, but ensure that any required dependencies are available on the target machines.

## Contact

For support or questions, please contact your IT department or refer to the system administrator.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

