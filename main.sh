#!/bin/bash

echo "*** Matty's Checkm8 APNonce Setter ***"
echo "Do you want to input a generator? (y,n)"

read -r input

if [ "$input" = y ]
then
    echo "Please enter your desiered generator."

    read -r generator

    echo "Your generator is $generator"
elif [ "$input" = n ]
then

    echo "Please drag and drop the SHSH file that you want to downgrade with into this terminal window then press enter"

    read -r shsh

    echo "Is $shsh the correct location and file name of your SHSH? (y/n)"

    read -r pass

        if [ "$pass" == yes ] || [ "$pass" == Yes ] || [ "$pass" == y ] || [ "$pass" == Y ]
        then
            echo "Continuing with given SHSH"

        elif [ "$pass" == no ] || [ "$pass" == No ] || [ "$pass" == n ] || [ "$pass" == n ]
        then
            echo "Please restart script and give the correct location and file name"
            echo "Exiting..."
            exit

        else
            echo "Unrecognised input"
            echo "Exiting..."
            exit

        fi

        if [ "${shsh: -6}" == ".shsh2" ] || [ "${shsh: -5}" == ".shsh" ]
        then
            echo "File verified as SHSH2 file, continuing"

        else
            echo "Please ensure that the file extension is either .shsh or .shsh2 and retry"
            echo "Exiting..."
            exit
        fi

        echo "Getting generator from SHSH"

        getGenerator() {
        echo "$1" | grep "<string>0x" "$shsh" | cut -c10-27
        }
        generator=$(getGenerator "$shsh")

        if [ -z "$generator" ]
        then
            echo "[ERROR] SHSH does not contain a generator!"
            echo "[ERROR] Please use a different SHSH with a generator!"
            echo "[ERROR] SHSH saved with shsh.host (will show generator) or tsssaver.1conan.com (in noapnonce folder) are acceptable"
            echo "Exiting..."
            exit
        else
            echo "Your generator is: $generator"
        fi

else
    echo "Input not recognized, Exiting..."
    exit
fi

echo "$generator"


if files/ideviceinfo -s -k HardwareModel | grep -i 'n53ap' &> /dev/null; then
   echo "Supported Device"
   device="iPhone6,2"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'n51ap' &> /dev/null; then
   echo "Supported Device"
   device="iPhone6,1"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'j71ap' &> /dev/null; then
   echo "Supported Device"
   device="iPad4,1"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'j72ap' &> /dev/null; then
   echo "Supported Device"
   device="iPad4,2"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'j85ap' &> /dev/null; then
   echo "Supported Device"
   device="iPad4,4"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'j86ap' &> /dev/null; then
   echo "Supported Device"
   device="iPad4,5"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'd11ap' &> /dev/null; then
   echo "Supported Device"
   device="iPhone9,2"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'd10ap' &> /dev/null; then
   echo "Supported Device"
   device="iPhone9,1"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'd101ap' &> /dev/null; then
   echo "Supported Device"
   device="iPhone9,3"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'd111ap' &> /dev/null; then
   echo "Supported Device"
   device="iPhone9,4"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'd22ap' &> /dev/null; then
   echo "Supported Device"
   device="iPhone10,3"
   echo $device
fi

if files/ideviceinfo -s -k HardwareModel | grep -i 'd221ap' &> /dev/null; then
   echo "Supported Device"
   device="iPhone10,6"
   echo $device
fi

if [ -z "$device" ]
then
    device=$(files/irecovery -q | grep PRODUCT | awk '{ print $2 }')
fi

if [ -z "$device" ]
then
    echo "Either unsupported device or no device found."
    echo "Exiting.."
    exit
else
    echo "Supported device found."
fi

echo "Please connect device in DFU mode."

echo "Starting gaster"
cd files || exit

while true
do
    echo "Attempting to get into pwndfu mode"
    echo "Please just enter DFU mode again on each reboot"
    echo "The script will run gaster again and again until the device is in PWNDFU mode"
    ./gaster pwn && ./gaster reset && break
done

sleep 3

echo "Device is now in PWNDFU mode with signature checks removed"

echo "Entering PWNREC mode"

./irecovery -f ibss."$device".img4

if [ "$device" = iPhone6,1 ] || [ "$device" = iPhone6,2 ] || [ "$device" = iPad4,1 ] || [ "$device" = iPad4,2 ] || [ "$device" = iPad4,3 ] || [ "$device" = iPad4,4 ] || [ "$device" = iPad4,5 ] || [ "$device" = iPad4,6 ] || [ "$device" = iPad4,7 ] || [ "$device" = iPad4,8 ] || [ "$device" = iPad4,9 ]
then
    ./irecovery -f ibec."$device".img4
fi

echo "Entered PWNREC mode"
sleep 4
echo "Current nonce"
./irecovery -q | grep NONC
echo "Setting nonce to $generator"
./irecovery -c "setenv com.apple.System.boot-nonce $generator"
sleep 1
./irecovery -c "saveenv"
sleep 1
./irecovery -c "setenv auto-boot false"
sleep 1
./irecovery -c "saveenv"
sleep 1
./irecovery -c "reset"
echo "Waiting for device to restart into recovery mode"
sleep 10
echo "New nonce"
./irecovery -q | grep NONC

echo "We are done!"
echo ""
echo "You can now futurerestore to the firmware that this SHSH is vaild for"
echo "Assuming that signed SEP and Baseband are compatible"
