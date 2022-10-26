#SingleInstance ignore
#Persistent
#NoEnv
SetWorkingDir %A_ScriptDir%
SendMode Input
#Include VMR.ahk/VMR.ahk

global voicemeeter
global OUTPUT := 1
global PathIsRelative := 1
global DefaultConfigPath := "Default.xml"
global VRConfigPath := "VR.xml"

IniRead, OUTPUT, config.ini, Settings, OUTPUT

IniRead, PathIsRelative, config.ini, Settings, PathIsRelative
IniRead, DefaultConfigPath, config.ini, Settings, DefaultConfigPath
IniRead, VRConfigPath, config.ini, Settings, VRConfigPath

ExitFunc(ExitReason, ExitCode)
{
    voicemeeter.reset()
    Sleep, 5000
}
OnExit("ExitFunc")

ProcessExist(Name){
	Process, Exist, %Name%
	return Errorlevel
}

voicemeeter := new Voicemeeter()
voicemeeter.loadConfig(VRConfigPath, PathIsRelative)

Sleep, 2000
While (master_volume != 70) {
    SoundGet, master_volume
    SoundSet, 70, master
}
Sleep, 5000

Loop {
    SoundGet, master_volume
    if (master_volume != lastVolume) {
        VMVolume := (master_volume * 0.6) - 60
        voicemeeter.setVolume(VMVolume)
        lastVolume := master_volume
    }
    Sleep, 1000
    if (!ProcessExist("vrmonitor.exe")) {
        ExitApp
    }
}

Class Voicemeeter {
    vm := ""
    
    __New() {
        this.vm := new VMR()
        this.vm.login()
    }

    setVolume(vol) {
        this.vm.bus[OUTPUT].gain := vol
    }

    loadConfig(filename, isRelative) {
        If (isRelative) {
            this.vm.command.load(A_ScriptDir . "\" . filename)
        }
        Else {
            this.vm.command.load(filename)
        }
    }

    reset() {
        this.loadConfig("default.xml", True)
    }
}