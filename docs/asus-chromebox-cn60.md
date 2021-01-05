# Asus Chromebox cn60
I inherited an [Asus Chromebox cn60](https://www.asus.com/gr/Chrome-Devices/Chromebox/ProductPrint/) recently that was locked to a google enterprise enrollment for a company that no longer exists.
It's the version with a haswell i7-4600U CPU, 4GB RAM, and a 16GB SSD.
It's not a particularly expensive machine these days, but since the RAM and SSD are both easily upgradeable, I figured it could be worth using as a low power linux server.

## Chrome OS Google Enterprise Enrollment
This device was "enterprise enrolled" to a company that no longer existed. [Enterprise entrollment](https://chromium.googlesource.com/chromium/src/+/master/docs/enterprise/enrollment.md) allows an organization to manage chromeboxes from a central google "organization" account.
This means that when I booted the cn60 I was met with a chrome OS login screen that wanted me to login with a google account.

To make it extra spicy, the BIOS is actually locked, so just installing a new OS via USB is non-trivial.

Luckily, there's a very active community around chrome OS devices, and one person in particular ([Mr Chromebox](https://mrchromebox.tech/)) has put in an incredible amount of work providing open source BIOS/UEFI firmwares.

These two links were *very* helpful:
- https://wiki.mrchromebox.tech/Unbricking
- https://sergei.nz/unbricking-asus-chromebox-cn60/

### Access the SPI chip
First step is to open the box and find the SPI chip.
The one in the i7 cn60 is a [Winbond 25Q64FVSIG](https://www.datasheetq.com/datasheet-download/840460/1/Winbond/25Q64FVSIG).
Unfortunately it's on the bottom of the board.

Opening the case isn't too difficult: there are four phillips screws on the bottom and then you can either try to pry the sides up or actually use two case screws in the two center (I think mounting??) holes which allows you to pretty easily pull the back off.
This will provide you access to RAM, SSD, and wifi modules. In order to replace the SSD, you'll need to take the wifi chip off, but it's pretty straightforwards.

Getting to the back of the board is a little trickier. You'll need to disconnect the cables to the wifi and [FILL IN MORE BOARD INFO HERE]

It might be worth taking a picture before disassembly if you're at all worried about what goes where and what connects to what 😁😁

On the back of the board, the SPI chip is underneath the fan, so that will need to come off [MORE REMOVING FAN INFO HERE W/ PICS!!!]

Ok yay, now the fan is off and we have direct access to the SPI chip 🎊

I used a CH341a USB flash programmer as recommended by mrchromebox. Because the SPI chip is 3v, the only thing we need is the programmer and a [SOIC-8 chip clip](https://www.amazon.com/gp/product/B00V9QNAC4/).

The chip clip is this very handy tool which lets us easily connect to each pin of the chip without any terrifying soldering. This is super handy for boards that don't just provide you with easy jumper pins access.

![directly soldered connections onto SPI chip](./soldered-connections.jpeg)

*This person was brave enough and had a steady enough hand to solder directly onto the pins of the chip on the board. I am neither :D*
Pic from https://sergei.nz/unbricking-asus-chromebox-cn60/

The SPI chip has a teensy dot on it where pin #1 goes. The CH341a also has a convenient little dot to mark pin #1 as well as a marking on the wire. [PICS HERE!!]

### Get the new firmware
Connect the chip clip and then plug the CH341a into your computer.

I used the `flashrom` command, which I believe comes by default in Ubuntu 20.04. If not, it's possible to `$ apt install flashrom`.

Start by checking that you have a good connection to the SPI chip:
```bash
$ flashrom -p ch341a_spi --flash-name
```
[ADD RESULTS HERE WHEN RUNNING COMMAND]

If this does not return the name of the winbond chip, re-attach the chip clip. It can be a little finnicky, so it's worth trying to reconnect a few times.

Once you know you have a good connection, you'll need to download the proper firmware. MrChromebox provides a few different options, [including a legacy seaBIOS firmware](https://mrchromebox.tech/#bootmodes), but it didn't look like there was any reason to use that one, so I figured I'd go for the fancier UEFI variant.

Download the coreboot firmware and check the sha1sum:
```bash
$ curl -s --output ./coreboot_tiano-panther-mrchromebox_20200618.rom https://mrchromebox.tech/files/firmware/full_rom/coreboot_tiano-panther-mrchromebox_20200618.rom
$ curl -s --output ./coreboot_tiano-panther-mrchromebox_20200618.rom.sha1 https://mrchromebox.tech/files/firmware/full_rom/coreboot_tiano-panther-mrchromebox_20200618.rom.sha1
$ sha1sum coreboot_tiano-panther-mrchromebox_20200618.rom
6516fd0b4e0b9b9a36084b76ad943ec9b6e81db0  coreboot_tiano-panther-mrchromebox_20200618.rom
$ cat coreboot_tiano-panther-mrchromebox_20200618.rom.sha1
6516fd0b4e0b9b9a36084b76ad943ec9b6e81db0  coreboot_tiano-panther-mrchromebox_20200618.rom
```

### Ethernet MAC VPD [OPTIONALish]
The ethernet device has it's MAC address stored in the VPD (vital product data) section of the stock firmware. If we flash the coreboot firmware we've just downloaded, the chromebox will end up with a default/generic MAC address.

In general, MAC addresses are supposed to be set to a globally unique identifier with a manufacturer prefix. In reality, it's trivial to spoof MAC addresses, so there's very little that depends on a unique MAC address guarantee. That being said, if you have two of these devices and you wanted them to be on the same LAN it's probably a good idea for them to have unique MAC addresses.

I would probably have skipped this part, but [MrChromebox provides such a thorough walkthrough of modifying the firmware to update the MAC from the original device](https://wiki.mrchromebox.tech/Unbricking) so I didn't really have a good excuse not to do it.

Get the cbfstool (coreboot filesystem tool) binary:
```bash
$ curl -s --output cbfstool.tar.gz https://mrchromebox.tech/files/util/cbfstool.tar.gz && tar -zxf cbfstool.tar.gz
```

Extract the VPD from the device's current firmware:
```bash
$ flashrom -p ch341a_spi -r original-firmware.rom
$ ./cbfstool original-firmware.rom read -r RO_VPD -f vpd.bin
```

Inject the VPD into the newly downloaded firmware:
```bash
$ ./cbfstool coreboot_tiano-panther-mrchromebox_20200618.rom add -n vpd.bin -f vpd.bin -t raw
```

Now our firmware will have the same MAC address as the device originally shipped with 🎉🎉🎉
### Write the new firmware
Now we can just write the new firmware to the device:
```bash
$ flashrom -p ch341a_spi -w coreboot_tiano-panther-mrchromebox_20200618.rom
```

It takes a little while, but it should output a verification step telling you that it's been successfuly flashed.

### Reassemble
It's relatively straightforwards to re-assemble, though I did find fitting the board back into the case a little tough and had to bend the metal frame of the case a *teensy* bit to get the board to fit back through 😬😅

## Install Linux!!
Once you re-attach everything, Put a USB with a live image on it, turn on the chromebox, and press escape as it turns on. It should give you the option of which drive to boot from and you can specify your live USB drive. From there, you can install Ubuntu (or whatever linux distro you prefer) as normal!!

And now I have a fully functioning little server in a box 😁😁
