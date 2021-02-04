# FSSC-Builder
FSSC PC code builder

This can be used to easily create media images for SMC Computer. Please read the tutorial below.

## Adding disks
Open **project.conf**. Then, add these lines and replace **name** with your disk's name and **size** with the disk size in bytes..
```
DiskName="name"
DiskSize=size
```
For example, I'll choose "Hard Disk" as the name and 20480 B as the size.
```
DiskName="Hard Disk"
DiskSize=20480
```

## Configuring disks
You can add a partition using these lines:
```
PartitionName[0]="name"
PartitionSize[0]=size
PartitionContent[0]="content"
PartitionAttributes[0]="attributes"
```
Replace **0** with the partition number. **It starts with 0**. Then, replace **name** with the partition name, **size** with the partition size and **content** with the path to your files that you want to be on this partition. In my case, it's **content/part0**. You can choose any name here.
Replace **attributes** with the path to your partition's attributes config file. See **config/part0.list** and **config/part1.list** for more info.

## Master Boot Record
If you want your media bootable in SMC Computer, add your MBR as **mbr** file. Contact me on Discord for more info about this.

## Building FSSC
After you set up your disks, just run **build.sh**.
```
chmod +x ./build.sh
./build.sh
```
*Make sure to run these commands **from the source tree directory**, otherwise you'll get errors and experience issues.*
Your FSSC PC code will be saved in **output.fssc**.
