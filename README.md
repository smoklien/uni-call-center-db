# Call Center Database

A relational database that was created with __MySQL Workbench__ for managing work of the call center

![database-diagram-dark](diagrams/database-diagram-dark.png)

# Database Structure

- `contact_info`: Contact information about person
- `staff`: Information about the company's staff
- `customer`: Customer's info
- `agent`: Info about call center's agent
- `supervisor`: Agent's supervisor
- `call`: Information about the call
- `service`: Services provided by the company
- `issue`: Customer's issue
- `call_service`: associative table
- `call_issue`: associative table

# Repository Structure

- `backup`: Folder that contains full backup of the database
- `data-files`: Folder that contains all data from the tables which is stored in `.csv` files
- `diagrams`: Folder that contains images of database diagrams created in __dbdiagrams__ and with __MySQL Workbench__ 
- `queries`: Folder that contains all __SQL__ queries that are designed to create and manage the database
- `database-presentation`: A `.pptx` presentation of the __Call Center Database__
- `.gitattributes`: File that gives attributes to pathnames

# Getting Started

## Windows

1. Download and Install __MySQL__:

    - Visit the [MySQL Downloads](https://dev.mysql.com/downloads/) page
    - Download the MySQL Installer for Windows
    - Run the installer and follow the installation instructions

2. Open __MySQL Command Line Client__:

    Run the following command to connect to your MySQL server as the root user:

    ```bash
    -h 127.0.0.1 -P 3306 -u root -p
    ```

    - `-h 127.0.0.1`: Specifies the hostname (localhost)
    - `-P 3306`: Specifies the port number (default MySQL port)
    - `-u root`: Specifies the username (root user)
    - `-p`: Prompts for the root user's password

3. Run the Backup File

    Use the `source` command to execute the SQL backup file and restore the database:

    ```bash
    source path-to-repository/call-center-db/backup/database-backup.sql;
    ```

    Replace `path-to-repository` with the actual path to your repository
    
## Linux

1. Download and Install __MySQL__:

    - Visit the [MySQL Downloads](https://dev.mysql.com/downloads/) page
    - Select the appropriate MySQL package for your Linux distribution
    - Follow the installation instructions provided on the MySQL website for your specific Linux distribution

2. Open Terminal and Launch MySQL Client:

    Run the following command to connect to your MySQL server as the root user:

    ```bash
    mysql -h 127.0.0.1 -P 3306 -u root -p
    ```

    - `-h 127.0.0.1`: Specifies the hostname (localhost)
    - `-P 3306`: Specifies the port number (default MySQL port)
    - `-u root`: Specifies the username (root user)
    - `-p`: Prompts for the root user's password

3. Run the Backup File

    Use the `source` command to execute the SQL backup file and restore the database:

    ```bash
    source path-to-repository/call-center-db/backup/database-backup.sql;
    ```

    Replace `path-to-repository` with the actual path to your repository
