<!-- markdownlint-configure-file { "MD004": { "style": "consistent" } } -->
<!-- markdownlint-disable MD033 -->
#

<p align="center">
  <img src="./assets/VentoyDocker.png" alt="VentoyDocker logo" width="300" />
  <br>
  <strong>Run Ventoy via Docker</strong>
</p>

<!-- markdownlint-enable MD033 -->

VentoyDocker is a project that provides a Docker container allowing you to run [Ventoy](https://www.ventoy.net/) in a Docker environment. 

- **Easy-to-use**: our scripts walk you through the simple use process
- **Free**: open source software that helps you create bootable USB drives
- **Enable Mac Support**: Ventoy officially does not have the support to run on macOS to create bootable usb device, but VentoyDocker enables Ventoy to work on macOS allowing you to create bootable USB drives using macOS.

-----

## Tutorial

[![VentoyDocker Demo](https://i.imgflip.com/a6j2jf.jpg)](https://youtu.be/70btP4Nli1w?si=pVojLN-cwY4qmqzo)

-----

## Getting Started

### Prerequisites
- Docker installed on your machine
- Qemu installed on your machine (for macOS users)
- A USB drive to use with Ventoy

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Mr-Sunglasses/VentoyDocker.git
   ```
2. Navigate to the project directory:
   ```bash
   cd VentoyDocker
   ``` 
3. Make the `StartVentoy.sh` and `StartNbd.sh` scripts executable:
   ```bash
   chmod +x StartVentoy.sh
   chmod +x StartNbd.sh
   ``` 
4. Start the NBD server:
   ```bash
   sudo ./StartNbd.sh -d <your-usb-drive-mount-path>
   ```

    - Note: You need to run this command with `sudo` to allow access to the disk image or USB drive.
    - The `-d` option specifies the USB drive mount path to use with Ventoy.
   - Replace `<your-usb-drive-mount-path>` with the mount path to your USB drive.

   - You can check the available USB drives and their mount path by running:
   ```bash
   diskutil list
   ```
   - Output of the Above command is like this:

   ```bash
   /dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *500.3 GB   disk0
   1:             Apple_APFS_ISC Container disk1         524.3 MB   disk0s1
   2:                 Apple_APFS Container disk3         494.4 GB   disk0s2
   3:        Apple_APFS_Recovery Container disk2         5.4 GB     disk0s3

   /dev/disk3 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +494.4 GB   disk3
                                 Physical Store disk0s2
   1:                APFS Volume Macintosh HD - Data     159.7 GB   disk3s1
   2:                APFS Volume Macintosh HD            12.0 GB    disk3s3
   3:              APFS Snapshot com.apple.os.update-... 12.0 GB    disk3s3s1
   4:                APFS Volume Preboot                 7.9 GB     disk3s4
   5:                APFS Volume Recovery                1.3 GB     disk3s5
   6:                APFS Volume VM                      1.1 GB     disk3s6

   /dev/disk4 (disk image):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        +105.9 MB   disk4
   1:                  Apple_HFS BetterDisplay           105.9 MB   disk4s1

   /dev/disk5 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *30.8 GB    disk5
   1:               Windows_NTFS Ventoy                  30.7 GB    disk5s1
   2:                       0xEF                         33.6 MB    disk5s 
   ```
   Choose the mount path of the USB drive in which you want to install ventoy. For example; I want to install ventoy in disk5 USB drive, then the mount path of that USB drive will be `/dev/disk5`

   __Note:__ The default port for NBD is `10809`, but you can specify a different port using the `-p` option:
   
   - Example: with defualt port for NBD: `10809`

   ```bash
   ./StartNbd.sh -d /dev/disk5
   ```

   - Example: with custom port for NBD: `1088`

   ```bash
   ./StartNbd.sh -d /dev/disk5 -p 1088
   ```

5. Start the Ventoy Docker container:
   ```bash
   ./StartVentoy.sh
   ```  

   __Note:__ You can specify the port to expose for VentoyWeb when starting the Ventoy Docker container which is Default to `24680`. To specify custom port apart from `24680` you can use `-p` flag.

   - Example:

   ```bash
   ./StartVentoy.sh -p 8080
   ```

6. Steps after starting the container:
   - The script will prompt you to connect to the NBD server from your host machine.
   - Use the command provided to connect to the NBD server:
     ```bash
     nbd-client host.docker.internal <your-nbd-port> <your-nbd-device>
     ```
   - Replace `<your-nbd-port>` with the port you specified (default is `10809`) and `<your-nbd-device>` with the device path (e.g., `/dev/nbd0`).
   - Optionally you can run the following script to connect to the NBD server from your host machine
     ```bash
     ./scrips/mount.sh
     ```


   - Before exiting the container, cleanly detach NBD, Clean Detach Procedure is essential to avoid data loss: 
        ```bash
        nbd-client -d <your-nbd-device>
        ```
   - Optionally you can run the following script cleanly detach NBD
        ```bash
         ./scripts/cleanup.sh
        ```

Now you can easily use Ventoy scripts to create bootable USB drives or disk images. For more information on how to use Ventoy scripts, refer to the [Ventoy documentation](https://www.ventoy.net/en/doc_start.html).

_📢 Important Notes:_
- ✅ Only the Ventoy CLI and Ventoy Web is currently supported in this project.
- ❌ Ventoy GUI interface are NOT supported.

----

### FAQ

1. How to run the VentoyWeb after starting the VentoyDocker container ?
- You can run the VentoyWeb using the following command in the docker container
```bash
./VentoyWeb.sh -H 0.0.0.0
```

and now you can access the ventoyweb interface on your hostmachine by going to `0.0.0.0:24680` in your browser.

__Note__: You can also specify which port to expose in the host machine; see the docs [here](#installation)

----

### Contributing via GitHub

We welcome _everyone_ to contribute to issue reports, suggest new features, and create pull requests.

If you have something to add - anything from a typo through to a whole new feature, we're happy to check it out! Just make sure to fill out our template when submitting your request; the questions it asks will help the volunteers quickly understand what you're aiming to achieve.

-----

## Authors

- [@Mr-Sunglasses](https://www.github.com/Mr-Sunglasses)

## License

[MIT](https://choosealicense.com/licenses/mit/)

## 💪 Thanks to all Wonderful Contributors

Thanks a lot for spending your time helping VentoyDocker grow.
Thanks a lot! Keep rocking 🍻

[![Contributors](https://contrib.rocks/image?repo=Mr-Sunglasses/VentoyDocker)](https://github.com/Mr-Sunglasses/VentoyDocker/graphs/contributors)

## 🙏 Support++

This project needs your shiny star ⭐.
Don't forget to leave a star ⭐️

[![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)](https://forthebadge.com)
