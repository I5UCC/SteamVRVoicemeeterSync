#SingleInstance ignore
#Persistent
#NoTrayIcon
#NoEnv
SetWorkingDir %A_ScriptDir%
SendMode Input
#Include VMR.ahk/VMR.ahk

global voicemeeter
global state

global OUTPUT_1 := 6
global OUTPUT_2 := 7
global OUTPUT_3 := 8
global VOLUME_CHANGE_AMOUNT := 0.5
global DEFAULT_VOLUME := -20

global running := 0

voicemeeter := new Voicemeeter()

Loop {
    While (!running) {
        If (ProcessExist("vrmonitor.exe"))
            running := 1
        Else
            Sleep, 5000
    }
    voicemeeter.setMainOutput("A4", True)
    voicemeeter.volumeMute(1, 1)
    voicemeeter.volumeMute(2, 0)
    voicemeeter.restart()

    Sleep, 5000
    SoundSet, 70

    While (ProcessExist("vrmonitor.exe")) {
        SoundGet, master_volume

        if (master_volume != lastVolume) {
            VMVolume := (master_volume * 0.6) - 60
            voicemeeter.setVolumes(VMVolume)
            lastVolume := master_volume
        }
        Sleep, 1000
    }
    voicemeeter.reset()
    running := 0
}

ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}

Class Voicemeeter {
    vm := ""
    
    __New() {
        this.vm := new VMR()
        this.vm.login()
    }

    volumeUp(strip) {
        this.vm.strip[strip].gain += VOLUME_CHANGE_AMOUNT
    }

    volumeDown(strip) {
        this.vm.strip[strip].gain -= VOLUME_CHANGE_AMOUNT
    }

    volumeMute(strip, v = -1) {
        if (v != -1)
            this.vm.strip[strip].mute := v
        Else
            this.vm.strip[strip].mute--
    }
    
    setMainOutput(output, unmute := True) {
        switch output {
            case "A2": 
                If (this.vm.strip[OUTPUT_1].A2)
                    output := "A1"
            case "A3":
                If (this.vm.strip[OUTPUT_1].A3)
                    output := "A1"
            case "A4":
                If (this.vm.strip[OUTPUT_1].A4)
                    output := "A1"
            case "A5":
                If (this.vm.strip[OUTPUT_1].A5)
                    output := "A1"
        }
        for i, strip in this.vm.strip {
            If (i > 5) {
                strip.A1 := 0
                strip.A2 := 0
                strip.A3 := 0
                strip.A4 := 0
                strip.A5 := 0
                switch output {
                    case "A1": strip.A1 := 1
                    case "A2": strip.A2 := 1
                    case "A3": strip.A3 := 1
                    case "A4": strip.A4 := 1
                    case "A5": strip.A5 := 1
                }
            }
            If (unmute)
                strip.mute := 0
        }
    }

    restart() {
        voicemeeter.vm.command.restart()
    }

    reset() {
        this.setMainOutput("A1")

        this.vm.strip[OUTPUT_1].gain := DEFAULT_VOLUME
        this.vm.strip[OUTPUT_2].gain := DEFAULT_VOLUME
        this.vm.strip[OUTPUT_3].gain := DEFAULT_VOLUME

        for i, strip in this.vm.strip {
            strip.mute := 0
        }

        this.restart()
    }
}