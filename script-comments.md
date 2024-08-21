# Script Configuration Comments

## Overview

This document provides instructions on how to configure the PowerShell script for managing Active Directory user passwords. It includes details on where to replace placeholders with actual values for your environment.

## Configuration Parameters

### Group Distinguished Name (DN)
- **Description**: The unique identifier for the Active Directory group used to authenticate administrators.
- **Format**: `CN=GroupName,OU=OrganizationalUnit,DC=DomainComponent,DC=TopLevelDomain`
- **How to Determine**: In Active Directory Users and Computers (ADUC), locate the group, right-click it, select "Properties", and go to the "Attribute Editor" tab. Find the "distinguishedName" attribute.
- **Example**: `CN=Admins,OU=IT,DC=example,DC=com`
- **Action**: Replace the placeholder with the DN of the AD group used for admin validation in your environment.

### Active Directory Server Address
- **Description**: The network address of your Active Directory server where the script will perform operations.
- **Format**: Fully qualified domain name (FQDN) or IP address.
- **How to Determine**: Obtain this from your network or system administrator. It is the address used to access the AD service.
- **Example**: `ad.example.com`
- **Action**: Replace the placeholder with the address of your AD server.

### Log File Path
- **Description**: The path where the script will save the log file for password changes.
- **Format**: Complete directory path where you have write permissions. The log file will be named based on the current date.
- **How to Determine**: Choose a directory on your system with sufficient space and write permissions. Ensure that the script can access this path.
- **Example**: `C:\Logs\PasswordChangeReports\PasswordChanges.html`
- **Action**: Replace the placeholder with the desired path for storing log files on your system.

## Instructions for Use

1. **Specify Group DN**:
   - Enter the distinguished name (DN) of the Active Directory group used for admin authentication when prompted.

2. **Enter AD Server Address**:
   - Provide the network address of your Active Directory server. This is the server the script will connect to for performing authentication and other operations.

3. **Set Log File Path**:
   - Specify the complete path where the script will save the log file. Ensure the path is writable by the script.

## Example Configuration

If your group DN is `CN=ITAdmins,OU=Support,DC=mycompany,DC=com`, your AD server address is `ad.mycompany.com`, and you want to save logs in `D:\PasswordLogs\ChangeReport.html`, you would input these values when prompted by the script.

## Additional Notes

- **Testing**: It is recommended to test the script in a non-production environment before deploying it in a live setting.
- **Permissions**: Ensure you have the necessary permissions to run the script and write to the specified log path.
- **Documentation**: For further details, consult your system administrator or refer to Active Directory documentation.

For any questions or issues, please reach out to your IT support team.
