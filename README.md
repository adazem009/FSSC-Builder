# FSSC-Builder
FSSC PC code builder

This can be used to easily create PC codes for SMC Computer. Please read the tutorial below.

## Adding disks
Open **project.conf** and remove the 2 default disks. Then, add these lines and replace **name** with your disk's name, **size** with the disk size in bytes. **config** with the path to your disk's config file and **bootable** with *true* or *false*.
```
DiskName[0]="name"
DiskSize[0]=size
DiskConfig[0]="config"
DiskBootable[0]=bootable
```
For example, I'll choose "Hard Disk" as the name and 20480 B as the size.
```
DiskName[0]="Hard Disk"
DiskSize[0]=20480
DiskConfig[0]="config/disk0.conf"
DiskBootable[0]=true
```
The recommended path for disk configs is the **config** directory, which can be found in the source tree. I set **DiskBootable** to *true*, because I want that disk to be bootable in SMC Computer.

I can now add more disks like this:
```
DiskName[1]="Second Disk"
DiskSize[1]=10240
DiskConfig[1]="config/disk1.conf"
DiskBootable[1]=true
```
Make sure to replace the number in the brackets with the disk number! It starts with **0** there.

## Configuring disks
Assuming that you placed your disk config file in **config/disk1.conf**, you can now open this file and start configuring. In case you downloaded the source code for the first time, delete the default config file, or remove the 2 partitions from it. You can add a partition using these lines:
```
PartitionName[0]="name"
PartitionSize[0]=size
PartitionContent[0]="content"
PartitionAttributes[0]="attributes"
```
Replace **0** with the partition number. Again, it starts with 0. Then, replace **name** with the partition name, **size** with the partition size and **content** with the path to your files that you want to be on this partition. In my case, it's **content/d0part0**. You can choose any name here.
Replace **attributes** with the path to your partition's attributes config file. See **content/d0part0.list** and **content/d0part1.list** for more info.

## Building FSSC
After you set up your disks, just run **build.sh**.
```
chmod +x ./build.sh
./build.sh
```
*Make sure to run these commands **from the source tree directory**, otherwise you'll get errors and experience bugs.*
Your FSSC PC code will be saved in **output.fssc**.
