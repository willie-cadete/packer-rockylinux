# Rocky Linux 9 Desktop

This project aims to create a Rocky Linux image with GUI using Packer and Vagrant with VMware. The resulting image can be used for various purposes such as development, testing, or production environments.

## Prerequisites

Before getting started, ensure that you have the following software installed on your macOS system:

- [Packer](https://www.packer.io/downloads): To install Packer using Homebrew, run the following command in your terminal:
    ```shell
    brew install packer
    ```

- [Vagrant](https://www.vagrantup.com/downloads): To install Vagrant using Homebrew and also VMware plugin, run the following command in your terminal:
    ```shell
    brew install vagrant
    vagrant plugin install vagrant-vmware-desktop
    ```

- [VMware Fusion](https://www.vmware.com/products/fusion.html) or [VMware Workstation](https://www.vmware.com/products/workstation-pro.html): To install VMware Fusion or VMware Workstation, visit their respective websites and follow the installation instructions.


## Installation

To install and build the Rocky Linux image, follow these steps:

1. Clone this repository to your local machine:

    ```shell
    git clone https://github.com/your-username/rocky-linux-image.git
    ```

2. Change into the project directory:

    ```shell
    cd rocky-linux-image
    ```

3. Initialize the Packer project:

    ```shell
    packer init .
    ```

4. Customize the Packer configuration file (`packer.pkr.hcl`) according to your requirements.

5. Build the image using Packer:

    ```shell
    packer build packer.pkr.hcl
    ```

6. Once the image is built, you can use Vagrant to create a virtual machine from the image:

    ```shell
    vagrant up --provider vmware_fusion
    ```

7. Access the virtual machine using SSH:

    ```shell
    vagrant ssh
    ```

## Usage

After successfully building the Rocky Linux image, you can use it for various purposes. Some common usage scenarios include:

- Development environment setup
- Testing and debugging applications
- Creating reproducible production environments

For more information on using Vagrant and VMware with the Rocky Linux image, refer to the official documentation.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request on the GitHub repository.

## Supported versions
The template was tested using the following softwares and versions:
- Packer 1.9.4
- Vagrant 2.4.0
- VMware Fusion 13.5.0

## License

This project is licensed under the [MIT License](LICENSE).
