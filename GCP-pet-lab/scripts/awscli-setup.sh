#!/bin/bash
sudo apt-get update

### AWS CLI version 1
# sudo apt-get install awscli -y

### AWS CLI version 2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


: << 'README'
AWS CLI version 1 and version 2 have several key differences:

1. **Installation and Packaging:**
   - **Version 1:** The AWS CLI version 1 is typically installed using package managers like `apt`, `yum`, or `pip`. This can lead to issues with dependencies and version management, especially when using `pip` in a shared environment.
   - **Version 2:** AWS CLI version 2 is packaged as a standalone installer, which simplifies the installation process. It includes all dependencies and is designed to work out of the box without requiring additional installations. This reduces the likelihood of version conflicts and makes it easier to manage.

2. **Improved Features and Functionality:**
   - **Version 1:** While version 1 has a wide range of features, it lacks some of the enhancements introduced in version 2.
   - **Version 2:** AWS CLI version 2 includes several new features, such as:
     - **AWS SSO (Single Sign-On) support:** Version 2 has built-in support for AWS SSO, allowing users to authenticate using SSO credentials.
     - **Automatic pagination:** Version 2 automatically handles pagination for commands that return large sets of results, making it easier to work with large datasets.
     - **Enhanced error messages:** Version 2 provides more informative error messages, which can help users troubleshoot issues more effectively.

3. **Configuration and Profiles:**
   - **Version 1:** Configuration and profile management are done through the `aws configure` command, and users often need to manually edit configuration files for advanced settings.
   - **Version 2:** AWS CLI version 2 introduces a more user-friendly configuration experience, including the ability to set up named profiles more easily. It also supports new configuration options, such as specifying the output format and region directly in the command line without needing to edit configuration files.
README

