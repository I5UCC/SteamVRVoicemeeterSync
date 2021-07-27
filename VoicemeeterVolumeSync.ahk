#SingleInstance ignore
#Persistent
;#NoTrayIcon
#NoEnv
SetWorkingDir %A_ScriptDir%
SendMode Input
#Include VMR.ahk/VMR.ahk

global voicemeeter
voicemeeter := new Voicemeeter()

Loop {
    WinWait, SteamVR Status
    voicemeeter.cmd("VR")

    While (WinExist("SteamVR Status")) {
        SoundGet, master_volume

        if (master_volume != lastVolume) {
            VMVolume := (master_volume * 0.6) - 60
            voicemeeter.setVolumes(VMVolume)
            lastVolume := master_volume
        }
        Sleep, 300
    }
    voicemeeter.cmd("RESET")
    Soundset, 100
}

;Methods
notImpl() {
    ;MsgBox, 64, NOT IMPLEMENTED, NOT IMPLEMENTED, 5
}

MessageBox(Message, Timeout) {
    MsgBox, 4097,, %Message%, %Timeout%
    IfMsgBox, Cancel
        Return False
    Return True
}

CMD(cmd, dir, bhide := False, wait := False) {
    If dir not contains :
        dir = %A_ScriptDir%%dir%
    
    If (!wait && !bhide)
        Run, %ComSpec% /c %cmd%, %dir%, Show
    Else If (wait && !bhide)
        RunWait, %ComSpec% /c %cmd%, %dir%, Show
    Else If (!wait && bhide)
        Run, %ComSpec% /c %cmd%, %dir%, Hide
    Else If (wait && bhide)
        RunWait, %ComSpec% /c %cmd%, %dir%, Hide
    
}

;Classes
Class Voicemeeter {
    vm := ""
    
    __New() {
        this.vm := new VMR()
        this.vm.login()
    }

    cmd(macrolabel) {
        switch macrolabel {
            case "RESET":
                this.setMainOutput("A1", True)

                this.vm.strip[1].Color_x := -0.26
                this.vm.strip[2].Color_x := -0.26

                this.vm.strip[6].gain := -20
                this.vm.strip[7].gain := -20
                this.vm.strip[8].gain := -20

                this.vm.strip[1].mute := 0
                this.vm.strip[2].mute := 1
                this.vm.command.restart()

            Return
            case "VR":
                this.setMainOutput("A4", True)

                this.vm.strip[1].mute := 1
                this.vm.strip[2].mute := 0

                this.vm.command.restart()
            Return
        }
    }

    setVolumes(vol) {
        this.vm.strip[6].gain := vol
        this.vm.strip[7].gain := vol
        this.vm.strip[8].gain := vol
    }
    
    setMainOutput(output, unmute := False) {
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
}
