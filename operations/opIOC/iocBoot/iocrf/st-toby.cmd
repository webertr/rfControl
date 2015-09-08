#!../../bin/linux-x86_64/rf

## You may have to change srcextr to something else
## everywhere it appears in this file

< envPaths

## Register all support components
dbLoadDatabase("../../dbd/rf.dbd")
rf_registerRecordDeviceDriver(pdbbase)



epicsThreadSleep(5)








####################################################################################################################################
#########################Configure Asyn Ports Connected to the Extractor SAM, PSHV/SEPTUM, EMC, PSARC/GasFlow Meter
####################################################################################################################################

##                  drvAsynIPPortConfigure("portName","hostAddress",priority,noAutoConnect,noProcessEOS)

##                  portName = Any Name that makes sense (Can be more than one port(name) per IP address
##                  hostAddress = IP address or name, and port # on tne network.  Assumed TCP unless specified - See documentation for other than TCP
##                  priority = Asyn I/O thread priority.  0 or missing = ThreadPriorityMedium
##                  noAutoConnect = Autoconnect status. 0 or missing = Autoconnect after disconnect or if connect timeout at boot.
##                  noProcessEOS = EOS in and out are specified if 0 or missing


#drvAsynIPPortConfigure(const char *portName, const char *hostInfo,
#                           unsigned int priority, int noAutoConnect,
#                           int noProcessEos);
drvAsynIPPortConfigure("MOD3InputRead", "192.168.0.198:502", 0,0,1)
drvAsynIPPortConfigure("MOD3CoilRead1", "192.168.0.198:502", 0,0,1)
drvAsynIPPortConfigure("MOD3CoilRead2", "192.168.0.198:502", 0,0,1)
drvAsynIPPortConfigure("MOD3Write", "192.168.0.198:502", 0,0,1)










##################################################################################################################################################
###############Allow previous IP Ports created to support Modbus Protocol
##################################################################################################################################################
##                  modbusInterposeConfig("portName", linkType, timeOutmSec, writeDelaymSec)

##                  portName = Name of previously configured IP port to attach Modbus communication to
##                  LinkType = 0 - TCP/IP
##                                   1 - RTU Serial
##                                   2 - ASCII Serial
##                  timeOutmSec = time in milliseconds for asynOctet has to complete read/write operations before timeout is reached and operation is
##                            aborted
##                  writeDelayMSec = minimum delay in milliseconds between modbus writes, useful for RTU and ascii comm, set to 0 for tcp comm.

# modbus-2-2 args: portName, linkType, timeoutMsec, writedelayMsec 
# no slaveAddress arg, writedelayMsec only used for serial RTU devices
modbusInterposeConfig("MOD3InputRead", 0, 1000, 0)
modbusInterposeConfig("MOD3CoilRead1", 0, 1000, 0)
modbusInterposeConfig("MOD3CoilRead2", 0, 1000, 0)
modbusInterposeConfig("MOD3Write", 0, 1000, 0)










##################################################################################################################################################
#####Configure Modbus Ports and assign them to IP Ports.  More than 1 Modbus port may be assigned to an IP Port
####################################################################################################################################
#drvModbusAsynConfigure(
#
#                      portName, - name of Modbus port to create
#
#                      tcpPortName, - name of previously created IP port to use  
#
#                      slaveAddress - For TCP communication the PLC ignores it so set to 0
#
#                      modbusFunction, - 1 Read Coil Status
#                                      - 2 Read Input Status
#                                      - 3 Read Holding Register
#                                      - 4 Read Input Register
#                                      - 5 Write Single Coil
#                                      - 6 Write Single Register
#                                      - 7 Read Exception Status
#                                      - 15 Write Multiple Coils (Requires additional Gensub code to put values in waveform record)
#                                      - 16 Write Multiple Registers (Requires additional Gensub code to put values in waveform record)
#                                      - 17 Report Slave ID
#
#                      modbusStartAddress, - Address in decimal or octal (add leading 0 if using octal e.g. 0177)
#
#                      modbusLength,  - number of 16 bit words to access for function codes 3,4,6,16, number of bits for codes 1,2,5,15
#
#                      dataType,     - Data format
#                                    - 0 UINT16, Unsigned 16bit Binary
#                                    - 1 INT16SM, 16 bit Binary, sign and magnitude.  Bit 15 is sign, 0-14 magnitude
#                                    - 2 BCD, unsigned
#                                    - 3 BCD, signed
#                                    - 4 INT16, signed 2's compliment
#                                    - 5 INT32_LE, 32 bit integer, little endian
#                                    - 6 INT32_LE, 32 bit integer, big endian
#                                    - 7 FLOAT32_LE, 32 bit floating point, little endian
#                                    - 8 FLOAT32_LE, 32 bit floating point, big endian
#                                    - 9 FLOAT64_LE, 64 bit floating point, little endian
#                                    - 10 FLOAT64_LE, 64 bit floating point, big endian
#
#                      pollMsec, - Polling delay time for read functions (This is the time resolution when using I/O interrupt scanning)
#
#                      plcType, - Any name, used in asynReport
#
## 

# NOTE: We use octal numbers for the start address and length (leading zeros)
#       to be consistent with the PLC nomenclature.  This is optional, decimal
#       numbers (no leading zero) or hex numbers can also be used.

# modbus-2-2 args: portName, tcpPortName, slaveAddress, modbusFunction, 
#                    modbusStartAddress, ModbusLength, datatype, pollMsec, plcType
# Read 1016 Inputs.  Function code=2.
drvModbusAsynConfigure("MOD3_Input", "MOD3InputRead", 0, 2, 0, 256, 0, 100, "Modicon")
drvModbusAsynConfigure("MOD3_Coil1", "MOD3CoilRead1", 0, 1, 0, 1400, 0, 100, "Modicon")
drvModbusAsynConfigure("MOD3_Coil2", "MOD3CoilRead2", 0, 1, 1768, 280, 0, 100, "Modicon")
drvModbusAsynConfigure("MOD3_Output", "MOD3Write", 0, 15, 1400, 368, 0, 100, "Modicon")








set_requestfile_path("autosaverequests")
set_savefile_path("../../../var/autosavefiles")





#Load Templates for Modicon Reads
dbLoadTemplate("MOD3ReadInputCoilsAlias.substitutions")
dbLoadTemplate("MOD3ReadOutputCoilsAlias1.substitutions")
dbLoadTemplate("MOD3ReadOutputCoilsAlias2.substitutions")
dbLoadTemplate("MOD3OutAlias.substitutions")






#Load calc records to prepare Modicon Writes - replaces genSub
dbLoadRecords("../../db/MOD3_calc_outputs.db")







####################################################################################################################################
##################### Setup the GPIB gateway for the Internal Steering Magnet
######################################################################################################################################


####################################################################################################################################
#########################Configure Asyn Ports Connected to the Extractor SAM, PSHV/SEPTUM, EMC, PSARC/GasFlow Meter
####################################################################################################################################

##                  drvAsynIPPortConfigure("portName","hostAddress",priority,noAutoConnect,noProcessEOS)

##                  portName = Any Name that makes sense (Can be more than one port(name) per IP address
##                  hostAddress = IP address or name, and port # on tne network.  Assumed TCP unless specified - See documentation for other than TCP
##                  priority = Asyn I/O thread priority.  0 or missing = ThreadPriorityMedium
##                  noAutoConnect = Autoconnect status. 0 or missing = Autoconnect after disconnect or if connect timeout at boot.
##                  noProcessEOS = EOS in and out are specified if 0 or missing


## Configure Port connected to RMC Acromag - 952EN, Combo I/O module, Input range of +/-10 VDC, output range 0-20 mA
drvAsynIPPortConfigure("RMCRead","192.168.0.182:502",0,0,1)

drvAsynIPPortConfigure("RMCWrite","192.168.0.183:502",0,0,1)

drvAsynIPPortConfigure("RPSC1Read","192.168.0.184:502",0,0,1)

drvAsynIPPortConfigure("RPSC2Read","192.168.0.185:502",0,0,1)

#drvAsynIPPortConfigure("RDRC1Read","192.168.0.186:502",0,0,1)

#drvAsynIPPortConfigure("RDRC1Write","192.168.0.187:502",0,0,1)

#drvAsynIPPortConfigure("RDRC2Read","192.168.0.188:502",0,0,1)

#drvAsynIPPortConfigure("RDRC2Write","192.168.0.189:502",0,0,1)

##################################################################################################################################################
###############Allow previous IP Ports created to support Modbus Protocol
##################################################################################################################################################
##                  modbusInterposeConfig("portName", linkType, timeOutmSec, writeDelaymSec)

##                  portName = Name of previously configured IP port to attach Modbus communication to
##                  LinkType = 0 - TCP/IP
##                                   1 - RTU Serial
##                                   2 - ASCII Serial
##                  timeOutmSec = time in milliseconds for asynOctet has to complete read/write operations before timeout is reached and operation is
##                            aborted
##                  writeDelayMSec = minimum delay in milliseconds between modbus writes, useful for RTU and ascii comm, set to 0 for tcp comm.

modbusInterposeConfig("RMCRead", 0, 1000, 0)

modbusInterposeConfig("RMCWrite", 0, 1000, 0)

modbusInterposeConfig("RPSC1Read", 0, 1000, 0)

modbusInterposeConfig("RPSC2Read", 0, 1000, 0)

#modbusInterposeConfig("RDRC1Read", 0, 1000, 0)

#modbusInterposeConfig("RDRC1Write", 0, 1000, 0)

#modbusInterposeConfig("RDRC2Read", 0, 1000, 0)

#modbusInterposeConfig("RDRC2Write", 0, 1000, 0)


##################################################################################################################################################
#####Configure Modbus Ports and assign them to IP Ports.  More than 1 Modbus port may be assigned to an IP Port
####################################################################################################################################
#drvModbusAsynConfigure(
#
#                      portName, - name of Modbus port to create
#
#                      tcpPortName, - name of previously created IP port to use  
#
#                      slaveAddress - For TCP communication the PLC ignores it so set to 0
#
#                      modbusFunction, - 1 Read Coil Status
#                                      - 2 Read Input Status
#                                      - 3 Read Holding Register
#                                      - 4 Read Input Register
#                                      - 5 Write Single Coil
#                                      - 6 Write Single Register
#                                      - 7 Read Exception Status
#                                      - 15 Write Multiple Coils (Requires additional Gensub code to put values in waveform record)
#                                      - 16 Write Multiple Registers (Requires additional Gensub code to put values in waveform record)
#                                      - 17 Report Slave ID
#
#                      modbusStartAddress, - Address in decimal or octal (add leading 0 if using octal e.g. 0177)
#
#                      modbusLength,  - number of 16 bit words to access for function codes 3,4,6,16, number of bits for codes 1,2,5,15
#
#                      dataType,     - Data format
#                                    - 0 UINT16, Unsigned 16bit Binary
#                                    - 1 INT16SM, 16 bit Binary, sign and magnitude.  Bit 15 is sign, 0-14 magnitude
#                                    - 2 BCD, unsigned
#                                    - 3 BCD, signed
#                                    - 4 INT16, signed 2's compliment
#                                    - 5 INT32_LE, 32 bit integer, little endian
#                                    - 6 INT32_LE, 32 bit integer, big endian
#                                    - 7 FLOAT32_LE, 32 bit floating point, little endian
#                                    - 8 FLOAT32_LE, 32 bit floating point, big endian
#                                    - 9 FLOAT64_LE, 64 bit floating point, little endian
#                                    - 10 FLOAT64_LE, 64 bit floating point, big endian
#
#                      pollMsec, - Polling delay time for read functions (This is the time resolution when using I/O interrupt scanning)
#
#                      plcType, - Any name, used in asynReport
#
##  

## Read and Write EMC Acromag

drvModbusAsynConfigure("RMCReadAll", "RMCRead",0,4,0,15,4,100,"Acromag")
#InterD Phase Shift PREAD 9 Offset; 0 Offset is Module Status. 

drvModbusAsynConfigure("InterDPhaseShift", "RMCWrite",0,6,1,1,4,100,"Acromag")

drvModbusAsynConfigure("RPSC1ReadAll", "RPSC1Read",0,4,0,15,4,100,"Acromag")
#I-CA PREAD 9 Offset; U-G1 PREAD 10 Offset; I-AN PREAD 11 Offset; I-G2 PREAD 12 Offset; 0 Offset is Module Status. 

drvModbusAsynConfigure("RPSC2ReadAll", "RPSC2Read",0,4,0,15,4,100,"Acromag")
#I-CA PREAD 9 Offset; U-G1 PREAD 10 Offset; I-AN PREAD 11 Offset; I-G2 PREAD 12 Offset; 0 Offset is Module Status. 

#drvModbusAsynConfigure("RDRC1ReadAll", "RDRC1Read",0,4,0,15,4,100,"Acromag")
#Forward Drive Power 9 Offset; Reflected Drive Power 10 Offset; Dee Voltage 11 Offset; Anode Voltage 12 Offset; Anode-Grid Phase 13 Offset; 0 Offset is Module Status.

#drvModbusAsynConfigure("Dee1VoltRef", "RDRC1Write",0,6,18,1,0,100,"Acromag")

#drvModbusAsynConfigure("RDRC2ReadAll", "RDRC2Read",0,4,0,15,4,100,"Acromag")
#Forward Drive Power 9 Offset; Reflected Drive Power 10 Offset; Dee Voltage 11 Offset; Anode Voltage 12 Offset; Anode-Grid Phase 13 Offset; 0 Offset is Module Status.

#drvModbusAsynConfigure("Dee2VoltRef", "RDRC2Write",0,6,18,1,0,100,"Acromag")






######################################################################################################################
######################################################################################################################
######################Load record instances
######################################################################################################################
######################################################################################################################


################################################################################################################################
##############################RF DC
################################################################################################################################


################################################################################################################################
##############################RMC RFDC Controls
################################################################################################################################

##############################Initialize RMC - Initialize. Clears Comm, Hardware, Acromag Cal Errors, and resets heartbeat.
dbLoadRecords("../../db/RFDC/RMC/RMCInitialize.vdb","SubSys=RF, Group=RFDC, Device=RMC")

###############################Read and write analog values for RMC. Handles InterD Phase Shift, PSET Read Back, and Heartbeat.
dbLoadRecords("../../db/RFDC/RMC/RMCAnalog.vdb","SubSys=RF, Group=RFDC, Device=RMC")

#############################RMC On/OFF. Turns on SB and HV PS Groups, and Turns Off All PS.
dbLoadRecords("../../db/RFDC/RMC/RMCOnOff.vdb","SubSys=RF, Group=RFDC, Device=RMC")

#############################RMC Check Interlocks
dbLoadRecords("../../db/RFDC/RMC/RMCCondition.vdb","SubSys=RF, Group=RFDC, Device=RMC")

#############################RMC Check Interlocks
dbLoadRecords("../../db/RFDC/RMC/RMCBeamInterlockCondition.vdb","SubSys=RF, Group=RFDC, Device=RMC")

## These create messages when pressed that say "Cannot $(Msg), $(Reason)." They are used to disable buttons (Ex. Init)
dbLoadRecords("../../db/RFDC/RMC/RMCPrevent.vdb","PV=RF:RFDC:RMC:BeamOn:Init,Msg=Init RFDC RMC,Reason=Beam On")
dbLoadRecords("../../db/RFDC/RMC/RMCPrevent.vdb","PV=RF:RFDC:RMC:Init:24Volt,Msg=Init RFDC RMC,Reason=No Control Volt")



#############################RMC TEMP UNTIL We get Some PS Interlock Status PVs
dbLoadRecords("../../db/RFDC/RMC/RMCTemp.vdb")





#########################RPSC 1 RFDC##############################


###############################Read analog values for RPSC. 
dbLoadRecords("../../db/RFDC/RPSC/RPSCAnalog.vdb","SubSys=RF, Group=RFDC, Device=RPSC1, Port=RPSC1ReadAll")

##############################Initialize RPSC - Initialize. Clears Comm, Hardware, and resets heartbeat.
dbLoadRecords("../../db/RFDC/RPSC/RPSCInitialize.vdb","SubSys=RF, Group=RFDC, Device=RPSC1")

#############################RPSC Check Interlocks
dbLoadRecords("../../db/RFDC/RPSC/RPSCBeamInterlockCondition.vdb","SubSys=RF, Group=RFDC, Device=RPSC1")

## These create messages when pressed that say "Cannot $(Msg), $(Reason)." They are used to disable buttons (Ex. Init)
dbLoadRecords("../../db/RFDC/RPSC/RPSCPrevent.vdb","PV=RF:RFDC:RPSC1:BeamOn:Init,Msg=Init RFDC RPSC1,Reason=Beam On")
dbLoadRecords("../../db/RFDC/RPSC/RPSCPrevent.vdb","PV=RF:RFDC:RPSC1:Init:24Volt,Msg=Init RFDC RPSC1,Reason=No Control Volt")






#########################RPSC 2 RFDC##############################


###############################Read analog values for RPSC. 
dbLoadRecords("../../db/RFDC/RPSC/RPSCAnalog.vdb","SubSys=RF, Group=RFDC, Device=RPSC2, Port=RPSC2ReadAll")

##############################Initialize RPSC - Initialize. Clears Comm, Hardware, and resets heartbeat.
dbLoadRecords("../../db/RFDC/RPSC/RPSCInitialize.vdb","SubSys=RF, Group=RFDC, Device=RPSC2")

#############################RPSC Check Interlocks
dbLoadRecords("../../db/RFDC/RPSC/RPSCBeamInterlockCondition.vdb","SubSys=RF, Group=RFDC, Device=RPSC2")

## These create messages when pressed that say "Cannot $(Msg), $(Reason)." They are used to disable buttons (Ex. Init)
dbLoadRecords("../../db/RFDC/RPSC/RPSCPrevent.vdb","PV=RF:RFDC:RPSC2:BeamOn:Init,Msg=Init RFDC RPSC2,Reason=Beam On")
dbLoadRecords("../../db/RFDC/RPSC/RPSCPrevent.vdb","PV=RF:RFDC:RPSC2:Init:24Volt,Msg=Init RFDC RPSC2,Reason=No Control Volt")





################################################################################################################################
##############################RF AC
################################################################################################################################


################################################################################################################################
##############################RMC AC Controls
################################################################################################################################

##############################Initialize RMC - Initialize. Clears Comm, Hardware, Acromag Cal Errors, and resets heartbeat.
dbLoadRecords("../../db/RFAC/RMC/RMCInitialize.vdb","SubSys=RF, Group=RFAC, Device=RMC")

###############################Read and write analog values for RMC. Handles InterD Phase Shift, PSET Read Back, and Heartbeat.
dbLoadRecords("../../db/RFAC/RMC/RMCAnalog.vdb","SubSys=RF, Group=RFAC, Device=RMC")

#############################RMC Check Interlocks
dbLoadRecords("../../db/RFAC/RMC/RMCCondition.vdb","SubSys=RF, Group=RFAC, Device=RMC")

#############################RMC Check Interlocks
dbLoadRecords("../../db/RFAC/RMC/RMCPhaseSet.vdb","SubSys=RF, Group=RFAC, Device=RMC")

#############################RMC Check Interlocks
dbLoadRecords("../../db/RFAC/RMC/RMCBeamInterlockCondition.vdb","SubSys=RF, Group=RFAC, Device=RMC")

#############################Define RMC Control Parameters
dbLoadRecords("../../db/RFAC/RMC/RMCParamSet.vdb","SubSys=RF, Group=RFAC, Device=RMC, Param=InterDPhase, NoAttach=1, Mult=.001, EGU=Deg, PREC=2, PWZ=.5, DRVH=187.5, DRVL=-7.5")

## These create messages when pressed that say "Cannot $(Msg), $(Reason)." They are used to disable buttons (Ex. Init)
dbLoadRecords("../../db/RFAC/RMC/RMCPrevent.vdb","PV=RF:RFAC:RMC:BeamOn:Init,Msg=Init RFAC RMC,Reason=Beam On")
dbLoadRecords("../../db/RFAC/RMC/RMCPrevent.vdb","PV=RF:RFAC:RMC:Init:24Volt,Msg=Init RFAC RMC,Reason=No Control Volt")

dbLoadRecords("../../db/RFAC/RMC/RMCPrevent.vdb","PV=RF:RFAC:RMC:BeamOn:Mode,Msg=Mode Set RMC,Reason=Beam On")
dbLoadRecords("../../db/RFAC/RMC/RMCPrevent.vdb","PV=RF:RFAC:RMC:Mode:24Volt,Msg=Mode Set RMC,Reason=No Control Volt")





################################################################################################################################
##############################RDRC AC Controls
################################################################################################################################

############SYSTEM 1##############################


##############################Initialize RDRC - Initialize. Clears Comm, Hardware, Acromag Cal Errors, and resets heartbeat.
#dbLoadRecords("../../db/RFAC/RDRC/RDRCInitialize.vdb","SubSys=RF, Group=RFAC, Device=RDRC1")

###############################Read and write analog values for RDRC. Handles InterD Phase Shift, PSET Read Back, and Heartbeat.
#dbLoadRecords("../../db/RFAC/RDRC/RDRCAnalog.vdb","SubSys=RF, Group=RFAC, Device=RDRC1, ReadPort=RDRC1ReadAll, WritePort=Dee1VoltRef")

#############################RDRC Check Interlocks
#dbLoadRecords("../../db/RFAC/RDRC/RDRCCondition.vdb","SubSys=RF, Group=RFAC, Device=RDRC1")

#############################RDRC Check Interlocks
#dbLoadRecords("../../db/RFAC/RDRC/RDRCBeamInterlockCondition.vdb","SubSys=RF, Group=RFAC, Device=RDRC1")

#############################Define RDRC Control Parameters
#dbLoadRecords("../../db/RFAC/RDRC/RDRCParamSet.vdb","SubSys=RF, Group=RFAC, Device=RDRC1, Param=DeeVoltRef, NoAttach=1, Mult=.001, EGU=kV, PREC=2, PWZ=.5, DRVH=50, DRVL=0")

## These create messages when pressed that say "Cannot $(Msg), $(Reason)." They are used to disable buttons (Ex. Init)
#dbLoadRecords("../../db/RFAC/RDRC/RDRCPrevent.vdb","PV=RF:RFAC:RDRC1:BeamOn:Init,Msg=Init RFAC RDRC1,Reason=Beam On")
#dbLoadRecords("../../db/RFAC/RDRC/RDRCPrevent.vdb","PV=RF:RFAC:RDRC1:Init:24Volt,Msg=Init RFAC RDRC1,Reason=No Control Volt")




############SYSTEM 2##############################


##############################Initialize RDRC - Initialize. Clears Comm, Hardware, Acromag Cal Errors, and resets heartbeat.
#dbLoadRecords("../../db/RFAC/RDRC/RDRCInitialize.vdb","SubSys=RF, Group=RFAC, Device=RDRC2")

###############################Read and write analog values for RDRC. Handles InterD Phase Shift, PSET Read Back, and Heartbeat.
#dbLoadRecords("../../db/RFAC/RDRC/RDRCAnalog.vdb","SubSys=RF, Group=RFAC, Device=RDRC2, ReadPort=RDRC2ReadAll, WritePort=Dee2VoltRef")

#############################RDRC Check Interlocks
#dbLoadRecords("../../db/RFAC/RDRC/RDRCCondition.vdb","SubSys=RF, Group=RFAC, Device=RDRC2")

#############################RDRC Check Interlocks
#dbLoadRecords("../../db/RFAC/RDRC/RDRCBeamInterlockCondition.vdb","SubSys=RF, Group=RFAC, Device=RDRC2")

#############################Define RDRC Control Parameters
#dbLoadRecords("../../db/RFAC/RDRC/RDRCParamSet.vdb","SubSys=RF, Group=RFAC, Device=RDRC2, Param=DeeVoltRef, NoAttach=1, Mult=.001, EGU=kV, PREC=2, PWZ=.5, DRVH=50, DRVL=0")

## These create messages when pressed that say "Cannot $(Msg), $(Reason)." They are used to disable buttons (Ex. Init)
#dbLoadRecords("../../db/RFAC/RDRC/RDRCPrevent.vdb","PV=RF:RFAC:RDRC2:BeamOn:Init,Msg=Init RFAC RDRC2,Reason=Beam On")
#dbLoadRecords("../../db/RFAC/RDRC/RDRCPrevent.vdb","PV=RF:RFAC:RDRC2:Init:24Volt,Msg=Init RFAC RDRC2,Reason=No Control Volt")







################################################################################################################################
##############################RF System Wide
################################################################################################################################



######################################################################################################################
# RF RESET
######################################################################################################################

##Load stdby 1 to stby 2 transition database
dbLoadRecords("../../db/RFSystemReset.vdb", "SubSys=RF")




######################################################################################################################
# Standby Transition Database
######################################################################################################################

##Need to modify this for the RDRC's
##Load stdby 1 to stby 2 transition database
dbLoadRecords("../../db/RFSystemSB1SB2.vdb", "SubSys=RF")

######################################################################################################################
# Load IOC Heartbeat database
######################################################################################################################

dbLoadRecords("../../db/IocHeartbeat.vdb", "SubSys=RF")



# now required in version 4.5
set_pass0_restoreFile(auto_positions.sav)
set_pass1_restoreFile(auto_settings.sav)





#response to the error callbackRequest: cbLow ring buffer full.
#I believe when the iocInit is run, there are to many changed values 
# and too many callbacks for I/O scan. THus we end up getting stale data from the modicon.
#see http://www.aps.anl.gov/epics/tech-talk/2010/msg00133.php
callbackSetQueueSize(4225)








######################################################################################################################
######################################################################################################################
# Initialize IOC
######################################################################################################################
######################################################################################################################

iocInit()


# save positions every five seconds
create_monitor_set("auto_positions.req",5)
#save settings every 10 minutes
create_monitor_set("auto_settings.req",600)



## Start any sequence programs
#seq maysSnc,"user=rootHost"
